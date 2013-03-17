module Capybara
  module RSpecMatchers
    class Matcher
      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
      end
    end

    class HaveSelector < Matcher
      def initialize(*args)
        @args = args
      end

      def matches?(actual)
        wrap(actual).assert_selector(*@args)
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_selector(*@args)
      end

      def description
        "have #{query.description}"
      end

      def query
        @query ||= Capybara::Query.new(*@args)
      end
    end

    class HaveText < Matcher
      attr_reader :type, :content, :options

      def initialize(*args)
        @type = args.shift if args.first.is_a?(Symbol)
        @content = args.shift
        @options = (args.first.is_a?(Hash))? args.first : {}
      end

      def matches?(actual)
        @actual = wrap(actual)
        @actual.has_text?(type, content, options)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.has_no_text?(type, content, options)
      end

      def failure_message_for_should
        message = Capybara::Helpers.failure_message(description, options)
        message << " in #{format(@actual.text(type))}"
        message
      end

      def failure_message_for_should_not
        failure_message_for_should.sub(/(to find)/, 'not \1')
      end

      def description
        "text #{format(content)}"
      end

      def format(content)
        content = Capybara::Helpers.normalize_whitespace(content) unless content.is_a? Regexp
        content.inspect
      end
    end

    class HaveTitle < Matcher
      attr_reader :title

      def initialize(title)
        @title = title
      end

      def matches?(actual)
        @actual = wrap(actual)
        @actual.has_title?(title)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.has_no_title?(title)
      end

      def failure_message_for_should
        "expected there to be title #{title.inspect} in #{@actual.title.inspect}"
      end

      def failure_message_for_should_not
        "expected there not to be title #{title.inspect} in #{@actual.title.inspect}"
      end

      def description
        "have title #{title.inspect}"
      end
    end

    def have_selector(*args)
      HaveSelector.new(*args)
    end

    def have_xpath(xpath, options={})
      HaveSelector.new(:xpath, xpath, options)
    end

    def have_css(css, options={})
      HaveSelector.new(:css, css, options)
    end

    def have_text(*args)
      HaveText.new(*args)
    end
    alias_method :have_content, :have_text

    def have_title(title)
      HaveTitle.new(title)
    end

    def have_link(locator, options={})
      HaveSelector.new(:link, locator, options)
    end

    def have_button(locator)
      HaveSelector.new(:button, locator)
    end

    def have_field(locator, options={})
      HaveSelector.new(:field, locator, options)
    end

    def have_checked_field(locator)
      HaveSelector.new(:field, locator, :checked => true)
    end

    def have_unchecked_field(locator)
      HaveSelector.new(:field, locator, :unchecked => true)
    end

    def have_select(locator, options={})
      HaveSelector.new(:select, locator, options)
    end

    def have_table(locator, options={})
      HaveSelector.new(:table, locator, options)
    end
  end
end
