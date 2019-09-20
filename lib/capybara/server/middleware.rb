# frozen_string_literal: true

module Capybara
  class Server
    class Middleware
      class Counter
        attr_reader :value

        def initialize
          @value = []
          @mutex = Mutex.new
        end

        def increment(env)
          @mutex.synchronize { @value.push(env) }
        end

        def decrement(env)
          @mutex.synchronize { @value.delete_at(@value.index(env)) }
        end
      end

      attr_reader :error

      def initialize(app, server_errors, extra_middleware = [])
        @app = app
        @extended_app = extra_middleware.inject(@app) do |ex_app, klass|
          klass.new(ex_app)
        end
        @counter = Counter.new
        @server_errors = server_errors
      end

      def pending_requests
        @counter.value.map { |env| env["REQUEST_URI"] }
      end

      def pending_requests?
        @counter.value.length.positive?
      end

      def clear_error
        @error = nil
      end

      def call(env)
        if env['PATH_INFO'] == '/__identify__'
          [200, {}, [@app.object_id.to_s]]
        else
          @counter.increment(env)
          begin
            @extended_app.call(env)
          rescue *@server_errors => e
            @error ||= e
            raise e
          ensure
            @counter.decrement(env)
          end
        end
      end
    end
  end
end
