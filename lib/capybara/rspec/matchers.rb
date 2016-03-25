# frozen_string_literal: true
module Capybara
  module RSpecMatchers
    class Matcher
      include ::RSpec::Matchers::Composable if defined?(::RSpec::Expectations::Version) && (Gem::Version.new(RSpec::Expectations::Version::STRING) >= Gem::Version.new('3.0'))

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
      end
    end

    class HaveSelector < Matcher
      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args)
        @args = args
      end

      def matches?(actual)
        wrap(actual).assert_selector(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message = e.message
        return false
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_selector(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message_when_negated = e.message
        return false
      end

      def description
        "have #{query.description}"
      end

      def query
        @query ||= Capybara::Queries::SelectorQuery.new(*@args)
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    class HaveText < Matcher
      attr_reader :type, :content, :options

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args)
        @args = args.dup

        # are set just for backwards compatability
        @type = args.shift if args.first.is_a?(Symbol)
        @content = args.shift
        @options = (args.first.is_a?(Hash))? args.first : {}
      end

      def matches?(actual)
        wrap(actual).assert_text(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message = e.message
        return false
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_text(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message_when_negated = e.message
        return false
      end

      def description
        "text #{format(content)}"
      end

      def format(content)
        content = Capybara::Helpers.normalize_whitespace(content) unless content.is_a? Regexp
        content.inspect
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    class HaveTitle < Matcher
      attr_reader :title

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args)
        @args = args

        # are set just for backwards compatability
        @title = args.first
      end

      def matches?(actual)
        wrap(actual).assert_title(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message = e.message
        return false
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_title(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message_when_negated = e.message
        return false
      end

      def description
        "have title #{title.inspect}"
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    class HaveCurrentPath < Matcher
      attr_reader :current_path

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args)
        @args = args

        # are set just for backwards compatability
        @current_path = args.first
      end

      def matches?(actual)
        wrap(actual).assert_current_path(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message = e.message
        return false
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_current_path(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message_when_negated = e.message
        return false
      end

      def description
        "have current path #{current_path.inspect}"
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    class BecomeClosed
      def initialize(options)
        @wait_time = Capybara::Queries::SelectorQuery.new(options).wait
      end

      def matches?(window)
        @window = window
        start_time = Capybara::Helpers.monotonic_time
        while window.exists?
          return false if (Capybara::Helpers.monotonic_time - start_time) > @wait_time
          sleep 0.05
        end
        true
      end

      def failure_message
        "expected #{@window.inspect} to become closed after #{@wait_time} seconds"
      end

      def failure_message_when_negated
        "expected #{@window.inspect} not to become closed after #{@wait_time} seconds"
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    class MatchSelector < Matcher
      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args)
        @args = args
      end

      def matches?(actual)
        actual.assert_matches_selector(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message = e.message
        return false
      end

      def does_not_match?(actual)
        actual.assert_not_matches_selector(*@args)
      rescue Capybara::ExpectationNotMet => e
        @failure_message_when_negated = e.message
        return false
      end

      def description
        "match #{query.description}"
      end

      def query
        @query ||= Capybara::Queries::MatchQuery.new(*@args)
      end

      # RSpec 2 compatibility:
      alias_method :failure_message_for_should, :failure_message
      alias_method :failure_message_for_should_not, :failure_message_when_negated
    end

    def have_selector(*args)
      HaveSelector.new(*args)
    end

    def match_selector(*args)
      MatchSelector.new(*args)
    end
    # defined_negated_matcher was added in RSpec 3.1 - it's syntactic sugar only since a user can do
    # expect(page).not_to match_selector, so not sure we really need to support not_match_selector for prior to RSpec 3.1
    ::RSpec::Matchers.define_negated_matcher :not_match_selector, :match_selector if defined?(::RSpec::Expectations::Version) && (Gem::Version.new(RSpec::Expectations::Version::STRING) >= Gem::Version.new('3.1'))


    def have_xpath(xpath, options={})
      HaveSelector.new(:xpath, xpath, options)
    end

    def match_xpath(xpath, options={})
      MatchSelector.new(:xpath, xpath, options)
    end

    def have_css(css, options={})
      HaveSelector.new(:css, css, options)
    end

    def match_css(css, options={})
      MatchSelector.new(:css, css, options)
    end

    def have_text(*args)
      HaveText.new(*args)
    end
    alias_method :have_content, :have_text

    def have_title(title, options = {})
      HaveTitle.new(title, options)
    end

    def have_current_path(path, options = {})
      HaveCurrentPath.new(path, options)
    end

    def have_link(locator, options={})
      HaveSelector.new(:link, locator, options)
    end

    def have_button(locator, options={})
      HaveSelector.new(:button, locator, options)
    end

    def have_field(locator, options={})
      HaveSelector.new(:field, locator, options)
    end

    def have_checked_field(locator, options={})
      HaveSelector.new(:field, locator, options.merge(:checked => true))
    end

    def have_unchecked_field(locator, options={})
      HaveSelector.new(:field, locator, options.merge(:unchecked => true))
    end

    def have_select(locator, options={})
      HaveSelector.new(:select, locator, options)
    end

    def have_table(locator, options={})
      HaveSelector.new(:table, locator, options)
    end

    ##
    # Wait for window to become closed.
    # @example
    #   expect(window).to become_closed(wait: 0.8)
    # @param options [Hash] optional param
    # @option options [Numeric] :wait (Capybara.default_max_wait_time) Maximum wait time
    def become_closed(options = {})
      BecomeClosed.new(options)
    end
  end
end
