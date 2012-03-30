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

      RETRY_DELAY = 0.05

      def initialize(session, base)
        @session = session
        @base = base
      end

      # overridden in subclasses, e.g. Capybara::Node::Element
      def reload
        self
      end

      def synchronize(opts = {})
        retries =
          if driver.wait?
            seconds = opts[:seconds] || Capybara.default_wait_time
            (seconds.to_f / RETRY_DELAY).round
          else
            0
          end

        if opts[:retry]
          while !(result = yield) && !retries.zero?
            sleep(RETRY_DELAY)
            reload if Capybara.automatic_reload
            retries -= 1
          end
          result
        else
          begin
            yield
          rescue => e
            raise if !driver.invalid_element_errors.include?(e.class) || retries.zero?
            sleep(RETRY_DELAY)
            reload if Capybara.automatic_reload
            retries -= 1
            retry
          end
        end
      end

    protected

      def driver
        session.driver
      end
    end
  end
end
