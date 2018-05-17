# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'rack'
require 'capybara/server/middleware'
require 'capybara/server/animation_disabler'

module Capybara
  class Server
    class << self
      def ports
        @ports ||= {}
      end
    end

    attr_reader :app, :port, :host

    def initialize(app, *deprecated_options, port: Capybara.server_port, host: Capybara.server_host, reportable_errors: Capybara.server_errors, extra_middleware: [])
      warn "Positional arguments, other than the application, to Server#new are deprecated, please use keyword arguments" unless deprecated_options.empty?
      @app = app
      @extra_middleware = extra_middleware
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
      return false if @server_thread&.join(0)

      begin
        res = if !using_ssl?
          http_connect
        else
          https_connect
        end
      rescue EOFError, Net::ReadTimeout
        res = https_connect
        @using_ssl = true
      end

      if res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPRedirection)
        return res.body == app.object_id.to_s
      end
    rescue SystemCallError
      false
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
      @middleware ||= Middleware.new(app, @reportable_errors, @extra_middleware)
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
      server&.close
    end
  end
end
