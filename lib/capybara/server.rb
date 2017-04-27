# frozen_string_literal: true
require 'uri'
require 'net/http'
require 'rack'

module Capybara
  class Server
    class Middleware
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

      attr_accessor :error

      def initialize(app, server_errors)
        @app = app
        @counter = Counter.new
        @server_errors = server_errors
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
          rescue *@server_errors => e
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

    def initialize(app, port=Capybara.server_port, host=Capybara.server_host, server_errors=Capybara.server_errors)
      @app = app
      @server_thread = nil # suppress warnings
      @host, @port, @server_errors = host, port, server_errors
      @port ||= Capybara::Server.ports[port_key]
      @port ||= find_available_port(host)
    end

    def reset_error!
      middleware.error = nil
    end

    def error
      middleware.error
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      res = Net::HTTP.start(host, port) { |http| http.get('/__identify__') }

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        return res.body == app.object_id.to_s
      end
    rescue SystemCallError
      return false
    end

    def wait_for_pending_requests
      Timeout.timeout(60) { sleep(0.01) while pending_requests? }
    rescue Timeout::Error
      raise "Requests did not finish in 60 seconds"
    end

    def boot
      unless responsive?
        Capybara::Server.ports[port_key] = port

        @server_thread = Thread.new do
          Capybara.server.call(middleware, port, host)
        end

        Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
      end
    rescue Timeout::Error
      raise "Rack application timed out during boot"
    else
      self
    end

  private

    def middleware
      @middleware ||= Middleware.new(app, @server_errors)
    end

    def port_key
      Capybara.reuse_server ? app.object_id : middleware.object_id
    end

    def pending_requests?
      middleware.pending_requests?
    end

    def find_available_port(host)
      server = TCPServer.new(host, 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end
end
