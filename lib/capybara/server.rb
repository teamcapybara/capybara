require 'uri'
require 'net/http'
require 'rack'

module Capybara
  class Server
    class Middleware
      class Session
        attr_accessor :error
        attr_reader :counter, :id

        def initialize(id)
          @counter = Counter.new
          @id = id
        end
      end

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

      def initialize(app)
        @app = app
        @sessions = Hash.new { |hash, key| hash[key] = Session.new(key) }
      end

      def session(session_id=nil)
        @sessions[session_id && session_id.to_s]
      end

      def error(session_id)
        session(session_id).error || session().error
      end

      def reset_error(session_id)
        if session(session_id).error
          session(session_id).error = nil
        else
          session().error = nil
        end
      end

      def pending_requests?(session_id)
        session(session_id).counter.value > 0 || session().counter.value > 0
      end

      def cookie_domain(hostname)
        if (/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(hostname))
          {}
        else
          {domain: hostname.split('.')[-2..-1].join(".")}
        end
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, ["#{@app.object_id.to_s}:#{self.object_id.to_s}"]]
        else
          request = Rack::Request.new(env)
          session_id = request.cookies["capybara_session_id"] || request.params.delete("capybara_session_id")

          current_session = session(session_id)
          current_session.counter.increment
          begin
            # @app.call(env)
            status, headers, body = @app.call(env)
            response = Rack::Response.new(body, status, headers)

            cookie_options = { value: session_id, expires: Time.now + 24*60*60, path: '/'}
            cookie_options.merge!(cookie_domain(request.host))
            response.set_cookie("capybara_session_id", cookie_options ) if session_id

            response.finish
          rescue *Capybara.server_errors => e
            current_session.error = e unless current_session.error
            raise e
          ensure
            current_session.counter.decrement
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
      @port ||= Capybara::Server.ports[Capybara.reuse_server ? @app.object_id : @middleware.object_id]
      @port ||= find_available_port
    end

    def reset_error!(session_id)
      @middleware.reset_error(session_id)
    end

    def error(session_id)
      @middleware.error(session_id)
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      res = Net::HTTP.start(host, @port) { |http| http.get('/__identify__') }

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        object_ids = res.body.split(':')
        if object_ids[0] == @app.object_id.to_s
          @middleware = ObjectSpace._id2ref(object_ids[1].to_i)
          return true
        else
          return
        end
      end
    rescue SystemCallError
      return false
    end

    def wait_for_pending_requests(session_id)
      Timeout.timeout(60) { sleep(0.01) while @middleware.pending_requests?(session_id) }
    rescue Timeout::Error
      raise "Requests did not finish in 60 seconds"
    end

    def boot
      unless responsive?
        Capybara::Server.ports[Capybara.reuse_server ? @app.object_id : @middleware.object_id] = @port

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
