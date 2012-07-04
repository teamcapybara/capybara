require 'uri'
require 'net/http'
require 'rack'

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
      path_url = if path =~ /^http/
        path
      else
        (Capybara.app_host || "http://#{host}:#{port}") + path.to_s
      end
      
      if Capybara.always_include_port
        uri = URI.parse(path_url)
        uri.port = port if uri.port == uri.default_port
        path_url = uri.to_s
      end
      
      path_url
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
