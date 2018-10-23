# frozen_string_literal: true

require 'capybara/rspec/compound'

module Capybara
  module RSpecMatchers
    class Matcher
      include ::Capybara::RSpecMatchers::Compound if defined?(::Capybara::RSpecMatchers::Compound)

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(*args, &filter_block)
        @args = args.dup
        @filter_block = filter_block
      end

      def wrap(actual)
        actual = actual.to_capybara_node if actual.respond_to?(:to_capybara_node)
        @context_el = if actual.respond_to?(:has_selector?)
          actual
        else
          Capybara.string(actual.to_s)
        end
      end

    private

      def session_query_args
        if @args.last.is_a? Hash
          @args.last[:session_options] = session_options
        else
          @args.push(session_options: session_options)
        end
        @args
      end

      def session_options
        @context_el ||= nil
        if @context_el.respond_to? :session_options
          @context_el.session_options
        elsif @context_el.respond_to? :current_scope
          @context_el.current_scope.session_options
        else
          Capybara.session_options
        end
      end
    end

    class WrappedElementMatcher < Matcher
      def matches?(actual)
        element_matches?(wrap(actual))
      rescue Capybara::ExpectationNotMet => err
        @failure_message = err.message
        false
      end

      def does_not_match?(actual)
        element_does_not_match?(wrap(actual))
      rescue Capybara::ExpectationNotMet => err
        @failure_message_when_negated = err.message
        false
      end
    end

    class HaveSelector < WrappedElementMatcher
      def element_matches?(el)
        el.assert_selector(*@args, &@filter_block)
      end

      def element_does_not_match?(el)
        el.assert_no_selector(*@args, &@filter_block)
      end

      def description
        "have #{query.description}"
      end

      def query
        @query ||= Capybara::Queries::SelectorQuery.new(*session_query_args, &@filter_block)
      end
    end

    class HaveAllSelectors < WrappedElementMatcher
      def element_matches?(el)
        el.assert_all_of_selectors(*@args, &@filter_block)
      end

      def does_not_match?(_actual)
        raise ArgumentError, 'The have_all_selectors matcher does not support use with not_to/should_not'
      end

      def description
        'have all selectors'
      end
    end

    class HaveNoSelectors < WrappedElementMatcher
      def element_matches?(el)
        el.assert_none_of_selectors(*@args, &@filter_block)
      end

      def does_not_match?(_actual)
        raise ArgumentError, 'The have_none_of_selectors matcher does not support use with not_to/should_not'
      end

      def description
        'have no selectors'
      end
    end

    class HaveAnySelectors < WrappedElementMatcher
      def element_matches?(el)
        el.assert_any_of_selectors(*@args, &@filter_block)
      end

      def does_not_match?(_actual)
        el.assert_none_of_selectors(*@args, &@filter_block)
      end

      def description
        'have any selectors'
      end
    end

    class MatchSelector < HaveSelector
      def element_matches?(el)
        el.assert_matches_selector(*@args, &@filter_block)
      end

      def element_does_not_match?(el)
        el.assert_not_matches_selector(*@args, &@filter_block)
      end

      def description
        "match #{query.description}"
      end

      def query
        @query ||= Capybara::Queries::MatchQuery.new(*session_query_args, &@filter_block)
      end
    end

    class HaveText < WrappedElementMatcher
      def element_matches?(el)
        el.assert_text(*@args)
      end

      def element_does_not_match?(el)
        el.assert_no_text(*@args)
      end

      def description
        "text #{format(text)}"
      end

      def format(content)
        content.inspect
      end

    private

      def text
        @args[0].is_a?(Symbol) ? @args[1] : @args[0]
      end
    end

    class HaveTitle < WrappedElementMatcher
      def element_matches?(el)
        el.assert_title(*@args)
      end

      def element_does_not_match?(el)
        el.assert_no_title(*@args)
      end

      def description
        "have title #{title.inspect}"
      end

    private

      def title
        @args.first
      end
    end

    class HaveCurrentPath < WrappedElementMatcher
      def element_matches?(el)
        el.assert_current_path(*@args)
      end

      def element_does_not_match?(el)
        el.assert_no_current_path(*@args)
      end

      def description
        "have current path #{current_path.inspect}"
      end

    private

      def current_path
        @args.first
      end
    end

    class NegatedMatcher
      include ::Capybara::RSpecMatchers::Compound if defined?(::Capybara::RSpecMatchers::Compound)

      def initialize(matcher)
        super()
        @matcher = matcher
      end

      def matches?(actual)
        @matcher.does_not_match?(actual)
      end

      def does_not_match?(actual)
        @matcher.matches?(actual)
      end

      def description
        "not #{@matcher.description}"
      end

      def failure_message
        @matcher.failure_message_when_negated
      end

      def failure_message_when_negated
        @matcher.failure_message
      end
    end

    class HaveStyle < WrappedElementMatcher
      def element_matches?(el)
        el.assert_style(*@args)
      end

      def does_not_match?(_actual)
        raise ArgumentError, 'The have_style matcher does not support use with not_to/should_not'
      end

      def description
        'have style'
      end
    end

    class BecomeClosed
      def initialize(options)
        @options = options
      end

      def matches?(window)
        @window = window
        @wait_time = Capybara::Queries::BaseQuery.wait(@options, window.session.config.default_max_wait_time)
        timer = Capybara::Helpers.timer(expire_in: @wait_time)
        while window.exists?
          return false if timer.expired?

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
    end

    # RSpec matcher for whether the element(s) matching a given selector exist
    # See {Capybara::Node::Matcher#assert_selector}
    def have_selector(*args, &optional_filter_block)
      HaveSelector.new(*args, &optional_filter_block)
    end

    # RSpec matcher for whether the element(s) matching a group of selectors exist
    # See {Capybara::Node::Matcher#assert_all_of_selectors}
    def have_all_of_selectors(*args, &optional_filter_block)
      HaveAllSelectors.new(*args, &optional_filter_block)
    end

    # RSpec matcher for whether no element(s) matching a group of selectors exist
    # See {Capybara::Node::Matcher#assert_none_of_selectors}
    def have_none_of_selectors(*args, &optional_filter_block)
      HaveNoSelectors.new(*args, &optional_filter_block)
    end

    # RSpec matcher for whether the element(s) matching any of a group of selectors exist
    # See {Capybara::Node::Matcher#assert_any_of_selectors}
    def have_any_of_selectors(*args, &optional_filter_block)
      HaveAnySelectors.new(*args, &optional_filter_block)
    end

    # RSpec matcher for whether the current element matches a given selector
    # See {Capybara::Node::Matchers#assert_matches_selector}
    def match_selector(*args, &optional_filter_block)
      MatchSelector.new(*args, &optional_filter_block)
    end

    %i[css xpath].each do |selector|
      define_method "have_#{selector}" do |expr, **options, &optional_filter_block|
        HaveSelector.new(selector, expr, options, &optional_filter_block)
      end

      define_method "match_#{selector}" do |expr, **options, &optional_filter_block|
        MatchSelector.new(selector, expr, options, &optional_filter_block)
      end
    end

    # @!method have_xpath(xpath, **options, &optional_filter_block)
    #   RSpec matcher for whether elements(s) matching a given xpath selector exist
    #   See {Capybara::Node::Matchers#has_xpath?}

    # @!method have_css(css, **options, &optional_filter_block)
    #   RSpec matcher for whether elements(s) matching a given css selector exist
    #   See {Capybara::Node::Matchers#has_css?}

    # @!method match_xpath(xpath, **options, &optional_filter_block)
    #   RSpec matcher for whether the current element matches a given xpath selector
    #   See {Capybara::Node::Matchers#matches_xpath?}

    # @!method match_css(css, **options, &optional_filter_block)
    #   RSpec matcher for whether the current element matches a given css selector
    #   See {Capybara::Node::Matchers#matches_css?}

    %i[link button field select table].each do |selector|
      define_method "have_#{selector}" do |locator = nil, **options, &optional_filter_block|
        HaveSelector.new(selector, locator, options, &optional_filter_block)
      end
    end

    # @!method have_link(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for links
    #   See {Capybara::Node::Matchers#has_link?}

    # @!method have_button(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for buttons
    #   See {Capybara::Node::Matchers#has_button?}

    # @!method have_field(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for links
    #   See {Capybara::Node::Matchers#has_field?}

    # @!method have_select(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for select elements
    #   See {Capybara::Node::Matchers#has_select?}

    # @!method have_table(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for table elements
    #   See {Capybara::Node::Matchers#has_table?}

    %i[checked unchecked].each do |state|
      define_method "have_#{state}_field" do |locator = nil, **options, &optional_filter_block|
        HaveSelector.new(:field, locator, options.merge(state => true), &optional_filter_block)
      end
    end

    # @!method have_checked_field(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for checked fields
    #   See {Capybara::Node::Matchers#has_checked_field?}

    # @!method have_unchecked_field(locator = nil, **options, &optional_filter_block)
    #   RSpec matcher for unchecked fields
    #   See {Capybara::Node::Matchers#has_unchecked_field?}

    # RSpec matcher for text content
    # See {Capybara::SessionMatchers#assert_text}
    def have_text(*args)
      HaveText.new(*args)
    end
    alias_method :have_content, :have_text

    def have_title(title, **options)
      HaveTitle.new(title, options)
    end

    # RSpec matcher for the current path
    # See {Capybara::SessionMatchers#assert_current_path}
    def have_current_path(path, **options)
      HaveCurrentPath.new(path, options)
    end

    # RSpec matcher for element style
    # See {Capybara::Node::Matchers#has_style?}
    def have_style(styles, **options)
      HaveStyle.new(styles, options)
    end

    %w[selector css xpath text title current_path link button field checked_field unchecked_field select table].each do |matcher_type|
      define_method "have_no_#{matcher_type}" do |*args, &optional_filter_block|
        NegatedMatcher.new(send("have_#{matcher_type}", *args, &optional_filter_block))
      end
    end
    alias_method :have_no_content, :have_no_text

    %w[selector css xpath].each do |matcher_type|
      define_method "not_match_#{matcher_type}" do |*args, &optional_filter_block|
        NegatedMatcher.new(send("match_#{matcher_type}", *args, &optional_filter_block))
      end
    end

    ##
    # Wait for window to become closed.
    # @example
    #   expect(window).to become_closed(wait: 0.8)
    # @param options [Hash] optional param
    # @option options [Numeric] :wait (Capybara.default_max_wait_time) Maximum wait time
    def become_closed(**options)
      BecomeClosed.new(options)
    end
  end
end
