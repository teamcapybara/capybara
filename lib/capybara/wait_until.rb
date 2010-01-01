module Capybara
  #Provides timeout similar to standard library Timeout, but avoids threads
  class WaitUntil

    class << self

      def timeout(seconds = 1, &block)
        start_time = Time.now

        result = nil

        until result
          return result if result = yield

          if (Time.now - start_time) > seconds
             raise TimeoutError
          end
        end
      end

    end
  end
end
