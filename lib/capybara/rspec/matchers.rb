module Capybara
  module RSpecMatchers
    class HaveSelector
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

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
      end

      def query
        @query ||= Capybara::Query.new(*@args)
      end
    end

    class HaveText
      attr_reader :text

      def initialize(text)
        @text = text
      end

      def matches?(actual)
        @actual = wrap(actual)
        @actual.has_text?(text)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.has_no_text?(text)
      end

      def failure_message_for_should
        "expected there to be text #{format(text)} in #{format(@actual.text)}"
      end

      def failure_message_for_should_not
        "expected there not to be text #{format(text)} in #{format(@actual.text)}"
      end

      def description
        "have text #{format(text)}"
      end

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
      end

      def format(text)
        text = Capybara::Helpers.normalize_whitespace(text) unless text.is_a? Regexp
        text.inspect
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

    def have_content(text)
      HaveText.new(text)
    end

    def have_text(text)
      HaveText.new(text)
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
