require 'uri'
require 'net/http'
require 'rack'

module Capybara
  class Server
    class Counter
      attr_reader :value

      def initialize
        @value = 0
        @mutex = Mutex.new
      end

      def increment
        @mutex.synchronize { @value += 1 }
      end

      def decrement
        @mutex.synchronize { @value -= 1 }
      end
    end

    class Middleware
      attr_accessor :error

      def initialize(app)
        @app = app
        @counter = Counter.new
      end

      def pending_requests?
        @counter.value > 0
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, [@app.object_id.to_s]]
        else
          @counter.increment
          begin
            @app.call(env)
          rescue *Capybara.server_errors => e
            @error = e unless @error
            raise e
          ensure
            @counter.decrement
          end
        end
      end
    end

    class << self
      def ports
        @ports ||= {}
      end
    end

    attr_reader :app, :port, :host

    def initialize(app, port=Capybara.server_port, host=Capybara.server_host)
      @app = app
      @middleware = Middleware.new(@app)
      @server_thread = nil # suppress warnings
      @host, @port = host, port
      @port ||= Capybara::Server.ports[@app.object_id]
      @port ||= find_available_port
    end

    def reset_error!
      @middleware.error = nil
    end

    def error
      @middleware.error
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      res = Net::HTTP.start(host, @port) { |http| http.get('/__identify__') }

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        return res.body == @app.object_id.to_s
      end
    rescue SystemCallError
      return false
    end

    def wait_for_pending_requests
      Timeout.timeout(60) { sleep(0.01) while @middleware.pending_requests? }
    rescue Timeout::Error
      raise "Requests did not finish in 60 seconds"
    end

    def boot
      unless responsive?
        Capybara::Server.ports[@app.object_id] = @port

        @server_thread = Thread.new do
          Capybara.server.call(@middleware, @port)
        end

        Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
      end
    rescue Timeout::Error
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
