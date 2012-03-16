require 'uri'
require 'net/http'
require 'rack'
require 'thin'

module Capybara
  class Server
    class Identify
      def initialize(app)
        @app = app
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, [@app.object_id.to_s]]
        else
          @app.call(env)
        end
      end
    end

    class << self
      def ports
        @ports ||= {}
      end
    end

    attr_reader :app, :port

    def initialize(app)
      @app = app
      @server_thread = nil # supress warnings
    end

    def host
      Capybara.server_host || "127.0.0.1"
    end

    def url(path)
      if path =~ /^http/
        path
      else
        (Capybara.app_host || "http://#{host}:#{port}") + path.to_s
      end
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      res = Net::HTTP.start(host, @port) { |http| http.get('/__identify__') }

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        return res.body == @app.object_id.to_s
      end
    rescue Errno::ECONNREFUSED, Errno::EBADF
      return false
    end

    def boot
      if @app
        @port = Capybara::Server.ports[@app.object_id]

        if not @port or not responsive?
          @port = Capybara.server_port || find_available_port
          Capybara::Server.ports[@app.object_id] = @port

          @server_thread = Thread.new do
            Capybara.server.call(Identify.new(@app), @port)
          end

          @server_thread.abort_on_exception = true

          Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
        end
      end
    rescue TimeoutError
      raise "Rack application timed out during boot"
    else
      self
    end

  private

    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      server.addr[1]
    ensure
      server.close if server
    end

  end
end

module Capybara
  module Thin
    class WhinyBackend < ::Thin::Backends::TcpServer
      class Connection < ::Thin::Connection
        def log_error(e = $!)
          raise e
        end
      end

      def initialize(host, port, *args)
        super(host, port)
      end

      def connect
        @signature = EventMachine.start_server(@host, @port, Connection, &method(:initialize_connection))
      end
    end
  end
end
