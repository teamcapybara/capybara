module Capybara
  module Node

    ##
    #
    # A {Capybara::Node::Base} represents either an element on a page through the subclass
    # {Capybara::Node::Element} or a document through {Capybara::Node::Document}.
    #
    # Both types of Node share the same methods, used for interacting with the
    # elements on the page. These methods are divided into three categories,
    # finders, actions and matchers. These are found in the modules
    # {Capybara::Node::Finders}, {Capybara::Node::Actions} and {Capybara::Node::Matchers}
    # respectively.
    #
    # A {Capybara::Session} exposes all methods from {Capybara::Node::Document} directly:
    #
    #     session = Capybara::Session.new(:rack_test, my_app)
    #     session.visit('/')
    #     session.fill_in('Foo', :with => 'Bar')    # from Capybara::Node::Actions
    #     bar = session.find('#bar')                # from Capybara::Node::Finders
    #     bar.select('Baz', :from => 'Quox')        # from Capybara::Node::Actions
    #     session.has_css?('#foobar')               # from Capybara::Node::Matchers
    #
    class Base
      attr_reader :session, :base, :parent

      include Capybara::Node::Finders
      include Capybara::Node::Actions
      include Capybara::Node::Matchers

      def initialize(session, base)
        @session = session
        @base = base
        @unsynchronized = false
      end

      # overridden in subclasses, e.g. Capybara::Node::Element
      def reload
        self
      end

      ##
      #
      # This method is Capybara's primary defence agains asynchronicity
      # problems. It works by attempting to run a given block of code until it
      # succeeds. The exact behaviour of this method depends on a number of
      # factors. Basically there are certain exceptions which, when raised
      # from the block, instead of bubbling up, are caught, and the block is
      # re-run.
      #
      # Certain drivers, such as RackTest, have no support for aynchronous
      # processes, these drivers run the block, and any error raised bubbles up
      # immediately. This allows faster turn around in the case where an
      # expectation fails.
      #
      # Only exceptions that are {Capybara::ElementNotFound} or any subclass
      # thereof cause the block to be rerun. Drivers may specify additional
      # exceptions which also cause reruns. This usually occurs when a node is
      # manipulated which no longer exists on the page. For example, the
      # Selenium driver specifies
      # `Selenium::WebDriver::Error::ObsoleteElementError`.
      #
      # As long as any of these exceptions are thrown, the block is re-run,
      # until a certain amount of time passes. The amount of time defaults to
      # {Capybara.default_wait_time} and can be overriden through the `seconds`
      # argument.
      #
      # @param [Integer] seconds          Number of seconds to retry this block
      # @return [Object]                  The result of the given block
      #
      def synchronize(seconds = Capybara.default_wait_time)
        # If this element is unsynchronized, or if the driver does not support
        # waiting, immediately yield to the block. No exceptions will be
        # rescued, nothing will be retried.
        return(yield) if @unsynchronized or not driver.wait?

        wait = WaitFactory.new(driver, seconds).build
        wait.until do |attempt|
          # If this isn't the first attempt, reload the element (if enabled).
          reload if Capybara.automatic_reload and attempt > 1
          yield
        end
      end

      ##
      #
      # Within the given block, prevent synchronize from having any effect.
      #
      # This is an internal method which should not be called unless you are
      # absolutely sure of what you're doing.
      #
      # @api private
      # @return [Object]                  The result of the given block
      #
      def unsynchronized
        orig = @unsynchronized
        @unsynchronized = true
        yield
      ensure
        @unsynchronized = orig
      end

    protected

      def driver
        session.driver
      end

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
            :tester   => Wait::PassiveTester,
            :logger   => SynchronizeLogger
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
end
