module Capybara

  module Node

    # A factory class for the Wait gem.
    class WaitFactory
      def initialize(driver, seconds)
        raise ArgumentError unless seconds > 0

        @driver  = driver
        @seconds = seconds
      end

      # Creates a new (or returns an existing) configured instance of the
      # Wait gem.
      def build
        @wait ||= Wait.new(
        :timeout  => timeout,
        :attempts => attempts,
        :delay    => delay,
        :rescue   => exceptions,
        :tester   => Wait::PassiveTester.new,
        :logger   => SynchronizeLogger.new
        )
      end

      private

      # Amount of time to timeout a block. Defaults to +30+ seconds.
      def timeout
        Capybara.synchronize_timeout || 30
      end

      # Estimates the the number of attempts based upon the given number of
      # seconds to wait.
      def attempts
        (@seconds / delay).ceil
      end

      # Amount of time to wait in between attempts. Defaults to +0.5+
      # seconds.
      def delay
        Capybara.synchronize_delay || 0.5
      end

      # Exceptions to rescue. Always includes Capybara::ElementNotFound,
      # delegates to the driver for others.
      def exceptions
        [Capybara::ElementNotFound, *@driver.invalid_element_errors]
      end

      # A Ruby logger that saves to disk when a +synchronize_log_pathname+
      # is specified. Otherwise, only warnings are output to the console.
      class SynchronizeLogger < Wait::DebugLogger
        def initialize
          @logger           = Logger.new(io)
          @logger.level     = level
          @logger.formatter = formatter
        end

        def io
          return(STDOUT) if console?

          if @io.nil?
            @io = pathname.open("a")
            @io.sync = true
          end

          @io
        end

        # Returns +true+ if log output ought to go to the console.
        def console?
          pathname.nil?
        end

        def pathname
          Capybara.synchronize_log_pathname
        end

        def level
          console? ? Logger::WARN : Logger::DEBUG
        end
      end # SynchronizeLogger
    end # WaitFactory
  end

end
