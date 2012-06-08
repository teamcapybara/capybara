module Capybara
  module RSpecMatchers
    class HaveSelector
      def initialize(*args)
        @args = args
      end

      def matches?(actual)
        wrap(actual).assert_selector!(*@args)
      end

      def does_not_match?(actual)
        wrap(actual).assert_no_selector!(*@args)
      end

      def description
        "has #{query.description}"
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

    class HaveMatcher
      attr_reader :name, :locator, :options, :failure_message, :actual

      def initialize(name, locator, options={}, &block)
        @name = name
        @locator = locator
        @options = options
        @failure_message = block
      end

      def arguments
        if options.empty? then [locator] else [locator, options] end
      end

      def matches?(actual)
        @actual = wrap(actual)
        @actual.send(:"has_#{name}?", *arguments)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.send(:"has_no_#{name}?", *arguments)
      end

      def failure_message_for_should
        if failure_message
          failure_message.call(actual, self)
        elsif(@options[:count])
          "expected #{selector_name} to be returned #{@options[:count]} times"
        else
          "expected #{selector_name} to return something"
        end
      end

      def failure_message_for_should_not
        "expected #{selector_name} not to return anything"
      end

      def description
        "has #{selector_name}"
      end

      def selector_name
        selector_name = "#{name} #{locator.inspect}"
        selector_name << " with text #{options[:text].inspect}" if options[:text]
        selector_name
      end

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
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
      HaveMatcher.new(:content, text.to_s) do |page, matcher|
        %(expected there to be content #{matcher.locator.inspect} in #{page.text.inspect})
      end
    end

    def have_text(text)
      HaveMatcher.new(:text, text.to_s) do |page, matcher|
        %(expected there to be text #{matcher.locator.inspect} in #{page.text.inspect})
      end
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
