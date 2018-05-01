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
            @error ||= e
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

    def initialize(app, *deprecated_options, port: Capybara.server_port, host: Capybara.server_host, reportable_errors: Capybara.server_errors)
      warn "Positional arguments, other than the application, to Server#new are deprecated, please use keyword arguments" unless deprecated_options.empty?
      @app = app
      @server_thread = nil # suppress warnings
      @host = deprecated_options[1] || host
      @reportable_errors = deprecated_options[2] || reportable_errors
      @using_ssl = false
      @port = deprecated_options[0] || port
      @port ||= Capybara::Server.ports[port_key]
      @port ||= find_available_port(host)
    end

    def reset_error!
      middleware.error = nil
    end

    def error
      middleware.error
    end

    def using_ssl?
      @using_ssl
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      begin
        res = if !@using_ssl
          http_connect
        else
          https_connect
        end
      rescue EOFError, Net::ReadTimeout
        res = https_connect
        @using_ssl = true
      end

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        return res.body == app.object_id.to_s
      end
    rescue SystemCallError
      return false
    end

    def wait_for_pending_requests
      start_time = Capybara::Helpers.monotonic_time
      while pending_requests?
        if (Capybara::Helpers.monotonic_time - start_time) > 60
          raise "Requests did not finish in 60 seconds"
        end
        sleep 0.01
      end
    end

    def boot
      unless responsive?
        Capybara::Server.ports[port_key] = port

        @server_thread = Thread.new do
          Capybara.server.call(middleware, port, host)
        end

        start_time = Capybara::Helpers.monotonic_time
        until responsive?
          if (Capybara::Helpers.monotonic_time - start_time) > 60
            raise "Rack application timed out during boot"
          end
          @server_thread.join(0.1)
        end
      end

      self
    end

  private

    def http_connect
      Net::HTTP.start(host, port, read_timeout: 2) { |http| http.get('/__identify__') }
    end

    def https_connect
      Net::HTTP.start(host, port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) { |http| http.get('/__identify__') }
    end

    def middleware
      @middleware ||= Middleware.new(app, @reportable_errors)
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
