module Capybara
  module RSpecMatchers
    class HaveSelector
      def initialize(*args)
        @args = args
      end

      def matches?(actual)
        @actual = wrap(actual)
        @actual.has_selector?(*@args)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.has_no_selector?(*@args)
      end

      def failure_message_for_should
        if normalized.failure_message
          normalized.failure_message.call(@actual, normalized)
        else
          "expected #{selector_name} to return something"
        end
      end

      def failure_message_for_should_not
        "expected #{selector_name} not to return anything"
      end

      def selector_name
        name = "#{normalized.name} #{normalized.locator.inspect}"
        name << " with text #{normalized.options[:text].inspect}" if normalized.options[:text]
        name
      end

      def wrap(actual)
        if actual.respond_to?("has_selector?")
          actual
        else
          Capybara.string(actual.to_s)
        end
      end

      def normalized
        @normalized ||= Capybara::Selector.normalize(*@args)
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

      def matches?(actual)
        @actual = wrap(actual)
        @actual.send(:"has_#{name}?", locator, *options)
      end

      def does_not_match?(actual)
        @actual = wrap(actual)
        @actual.send(:"has_no_#{name}?", locator, *options)
      end

      def failure_message_for_should
        if failure_message
          failure_message.call(actual, self)
        else
          "expected #{selector_name} to return something"
        end
      end

      def failure_message_for_should_not
        "expected #{selector_name} not to return anything"
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

    def have_xpath(path, options={})
      HaveMatcher.new(:xpath, path, options)
    end

    def have_css(css, options={})
      HaveMatcher.new(:css, css, options)
    end

    def have_content(text)
      HaveMatcher.new(:content, text.to_s) do |page, matcher|
        %(expected there to be content #{matcher.locator.inspect} in #{page.text.inspect})
      end
    end

    def have_button(button, options={})
      HaveMatcher.new(:button, button, options) do |page, matcher|
        buttons = page.all(:xpath, './/button | .//input[(type="submit") or (type="image") or (type="button")]')
        labels = buttons.map { |button| %("#{button.text}") }.join(', ')
        %(expected there to be a button #{matcher.locator.inspect}, other buttons: #{labels})
      end
    end
  end
end
