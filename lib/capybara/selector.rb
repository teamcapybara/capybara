module Capybara
  class Selector
    # @deprecated  This alias will be removed in Capybara 3.0.
    Filter = ElementType::Filter

    attr_reader :name, :format

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
    end

    def initialize(name, &block)
      @name = name
      @match = nil
      @element_type = Capybara::ElementType.add(name, &block)
      instance_eval(&block)
    end

    def xpath(&block)
      @format = :xpath
      @xpath = block if block
      @xpath
    end

    def css(&block)
      @format = :css
      @css = block if block
      @css
    end

    def match(&block)
      @match = block if block
      @match
    end

    def call(locator)
      if @format==:css
        @css.call(locator)
      else
        @xpath.call(locator)
      end
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    # @!macro use_element_type
    #   @deprecated  This method will be removed in Capybara 3.0. Register element type using Capybara.register_element_type
    def label(label = nil)
      @element_type.label(label)
    end

    # @macro use_element_type
    def filter(name, options = {}, &block)
      @element_type.filter(name, options, &block)
    end

    # @macro use_element_type
    def description(options = {})
      @element_type.description(options)
    end

    # @macro use_element_type
    def describe(&block)
      @element_type.describe(&block)
    end
  end
end
