module Capybara
  class Selector
    attr_reader :name, :options, :block

    class << self
      def all
        @selectors ||= {}
      end

      def add(name, options={}, &block)
        all[name.to_sym] = Capybara::Selector.new(name.to_sym, options, &block)
      end

      def remove(name)
        all.delete(name.to_sym)
      end

      def normalize(name_or_locator, locator=nil)
        if locator
          all[name_or_locator.to_sym].call(locator)
        else
          selector = all.values.find { |s| s.match?(name_or_locator) }
          selector ||= all[Capybara.default_selector]
          selector.call(name_or_locator)
        end
      end
    end

    def initialize(name, options={}, &block)
      @name = name
      @options = options
      @block = block
    end

    def call(locator)
      @block.call(locator)
    end

    def match?(locator)
      @options[:for] and @options[:for] === locator
    end
  end
end

Capybara::Selector.add(:xpath) { |xpath| xpath }
Capybara::Selector.add(:css) { |css| XPath::HTML.from_css(css) }
Capybara::Selector.add(:id, :for => Symbol) { |id| XPath.descendant(:*)[XPath.attr(:id) == id.to_s] }
