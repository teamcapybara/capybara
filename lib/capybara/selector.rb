module Capybara
  class Selector
    attr_reader :name

    class << self
      def all
        @selectors ||= {}
      end

      def add(name, &block)
        all[name.to_sym] = Capybara::Selector.new(name.to_sym, &block)
      end

      def remove(name)
        all.delete(name.to_sym)
      end

      def normalize(*args)
        result = {}
        result[:options] = if args.last.is_a?(Hash) then args.pop else {} end

        if args[1]
          result[:selector] = all[args[0]]
          result[:locator] = args[1]
        else
          result[:selector] = all.values.find { |s| s.match?(args[0]) }
          result[:locator] = args[0]
        end
        result[:selector] ||= all[Capybara.default_selector]

        xpath = result[:selector].call(result[:locator])
        if xpath.respond_to?(:to_xpaths)
          result[:xpaths] = xpath.to_xpaths
        else
          result[:xpaths] = [xpath.to_s].flatten
        end
        result
      end
    end

    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    def xpath(&block)
      @xpath = block if block
      @xpath
    end

    def match(&block)
      @match = block if block
      @match
    end

    def failure_message(&block)
      @failure_message = block if block
      @failure_message
    end

    def call(locator)
      @xpath.call(locator)
    end

    def match?(locator)
      @match and @match.call(locator)
    end
  end
end

Capybara.add_selector(:xpath) do
  xpath { |xpath| xpath }
end

Capybara.add_selector(:css) do
  xpath { |css| XPath.css(css) }
end

Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
  match { |value| value.is_a?(Symbol) }
end
