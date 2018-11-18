# frozen_string_literal: true

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

      attr_reader :error

      def initialize(app, server_errors, extra_middleware = [])
        @app = app
        @extended_app = extra_middleware.inject(@app) do |ex_app, klass|
          klass.new(ex_app)
        end
        @counter = Counter.new
        @server_errors = server_errors
      end

      def pending_requests?
        @counter.value.positive?
      end

      def clear_error
        @error = nil
      end

      def call(env)
        if env['PATH_INFO'] == '/__identify__'
          [200, {}, [@app.object_id.to_s]]
        elsif (m = env["PATH_INFO"].match(%r{/__clear_storage__(?:/(local|session))?}))
          [200, {}, [<<~HTML
            <html>
              <head>
                <title>Clear Storage</title>
                <script>
                  #{'if (window.localStorage) window.localStorage.clear();' if m[1].nil? || m[1] == 'local'}
                  #{'if (window.sessionStorage) window.sessionStorage.clear();' if m[1].nil? || m[1] == 'session'}
                </script>
              </head>
              <body>
                Clearing Storage
              </body>
            </html>
          HTML
          ]]
        else
          @counter.increment
          begin
            @extended_app.call(env)
          rescue *@server_errors => err
            @error ||= err
            raise err
          ensure
            @counter.decrement
          end
        end
      end
    end
  end
end
