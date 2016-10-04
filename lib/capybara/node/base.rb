# frozen_string_literal: true
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
    #     session.fill_in('Foo', with: 'Bar')    # from Capybara::Node::Actions
    #     bar = session.find('#bar')                # from Capybara::Node::Finders
    #     bar.select('Baz', from: 'Quox')        # from Capybara::Node::Actions
    #     session.has_css?('#foobar')               # from Capybara::Node::Matchers
    #
    class Base
      attr_reader :session, :base, :query_scope

      include Capybara::Node::Finders
      include Capybara::Node::Actions
      include Capybara::Node::Matchers

      def initialize(session, base)
        @session = session
        @base = base
      end

      # overridden in subclasses, e.g. Capybara::Node::Element
      def reload
        self
      end

      ##
      #
      # This method is Capybara's primary defence against asynchronicity
      # problems. It works by attempting to run a given block of code until it
      # succeeds. The exact behaviour of this method depends on a number of
      # factors. Basically there are certain exceptions which, when raised
      # from the block, instead of bubbling up, are caught, and the block is
      # re-run.
      #
      # Certain drivers, such as RackTest, have no support for asynchronous
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
      # {Capybara.default_max_wait_time} and can be overridden through the `seconds`
      # argument. This time is compared with the system time to see how much
      # time has passed. On rubies/platforms which don't support access to a monotonic process clock
      # if the return value of `Time.now` is stubbed out, Capybara will raise `Capybara::FrozenInTime`.
      #
      # @param  [Integer] seconds         Number of seconds to retry this block
      # @param options [Hash]
      # @option options [Array<Exception>] :errors (driver.invalid_element_errors +
      #   [Capybara::ElementNotFound]) exception types that cause the block to be rerun
      # @return [Object]                  The result of the given block
      # @raise  [Capybara::FrozenInTime]  If the return value of `Time.now` appears stuck
      #
      def synchronize(seconds=Capybara.default_max_wait_time, options = {})
        start_time = Capybara::Helpers.monotonic_time

        if session.synchronized
          yield
        else
          session.synchronized = true
          begin
            yield
          rescue => e
            session.raise_server_error!
            raise e unless driver.wait?
            raise e unless catch_error?(e, options[:errors])
            raise e if (Capybara::Helpers.monotonic_time - start_time) >= seconds
            sleep(0.05)
            raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Capybara::Helpers.monotonic_time == start_time
            reload if Capybara.automatic_reload
            retry
          ensure
            session.synchronized = false
          end
        end
      end

      # @api private
      def find_css(css)
        base.find_css(css)
      end

      # @api private
      def find_xpath(xpath)
        base.find_xpath(xpath)
      end

      # @deprecated Use query_scope instead
      def parent
        warn "DEPRECATED: #parent is deprecated in favor of #query_scope - Note: #parent was not the elements parent in the document so it's most likely not what you wanted anyway"
        query_scope
      end

    protected

      def catch_error?(error, errors = nil)
        errors ||= (driver.invalid_element_errors + [Capybara::ElementNotFound])
        errors.any? do |type|
          error.is_a?(type)
        end
      end

      def driver
        session.driver
      end
    end
  end
end
