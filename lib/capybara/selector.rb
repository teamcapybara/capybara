module Capybara
  class Selector
    PROPERTY_OPTION_KEYS = [:text, :visible, :with, :checked, :unchecked, :selected]

    attr_reader :name, :custom_filters

    class Normalized
      attr_accessor :selector, :locator, :options, :xpath_options, :property_options, :xpaths

      def failure_message; selector.failure_message; end
      def name; selector.name; end

      def filter(node)
        return false if property_options[:text]      and not node.text.match(property_options[:text])
        return false if property_options[:visible]   and not node.visible?
        return false if property_options[:with]      and not node.value == property_options[:with]
        return false if property_options[:checked]   and not node.checked?
        return false if property_options[:unchecked] and node.checked?
        return false if property_options[:selected]  and not has_selected_options?(node, property_options[:selected])
        selector.custom_filters.each do |name, block|
          return false if options.has_key?(name) and not block.call(node, options[name])
        end
        true
      end

      private

      def has_selected_options?(node, expected)
        actual = node.all(:xpath, './/option').select { |option| option.selected? }.map { |option| option.text }
        (expected - actual).empty?
      end
    end

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
        normalized = Normalized.new
        normalized.options = if args.last.is_a?(Hash) then args.pop else {} end
        normalized.xpath_options, normalized.property_options = split_options(normalized.options)

        if args[1]
          normalized.selector = all[args[0]]
          normalized.locator = args[1]
        else
          normalized.selector = all.values.find { |s| s.match?(args[0]) }
          normalized.locator = args[0]
        end
        normalized.selector ||= all[Capybara.default_selector]

        xpath = normalized.selector.call(normalized.locator, normalized.xpath_options)
        if xpath.respond_to?(:to_xpaths)
          normalized.xpaths = xpath.to_xpaths
        else
          normalized.xpaths = [xpath.to_s].flatten
        end
        normalized
      end

      private

      def split_options(options)
        xpath_options = options.dup
        property_options = PROPERTY_OPTION_KEYS.inject({}) do |opts, key|
          opts[key] = xpath_options.delete(key) if xpath_options.has_key?(key)
          opts
        end

        [ xpath_options, property_options ]
      end
    end

    def initialize(name, &block)
      @name = name
      @custom_filters = {}
      instance_eval(&block)
    end

    def xpath(&block)
      @xpath = block if block
      @xpath
    end

    # Same as xpath, but wrap in XPath.css().
    def css(&block)
      if block
        @xpath = xpath { |*args| XPath.css(block.call(*args)) }
      end
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

    def call(locator, xpath_options={})
      @xpath.call(locator, xpath_options)
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, &block)
      @custom_filters[name] = block
    end
  end
end

Capybara.add_selector(:xpath) do
  xpath { |xpath| xpath }
end

Capybara.add_selector(:css) do
  css { |css| css }
end

Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
  match { |value| value.is_a?(Symbol) }
end

Capybara.add_selector(:field) do
  xpath { |locator| XPath::HTML.field(locator) }
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  xpath { |locator| XPath::HTML.link_or_button(locator) }
  failure_message { |node, selector| "no link or button '#{selector.locator}' found" }
end

Capybara.add_selector(:link) do
  xpath { |locator, xpath_options| XPath::HTML.link(locator, xpath_options) }
  failure_message { |node, selector| "no link with title, id or text '#{selector.locator}' found" }
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
  failure_message { |node, selector| "no button with value or id or text '#{selector.locator}' found" }
end

Capybara.add_selector(:fillable_field) do
  xpath { |locator, xpath_options| XPath::HTML.fillable_field(locator, xpath_options) }
  failure_message { |node, selector| "no text field, text area or password field with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:radio_button) do
  xpath { |locator, xpath_options| XPath::HTML.radio_button(locator, xpath_options) }
  failure_message { |node, selector| "no radio button with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:checkbox) do
  xpath { |locator, xpath_options| XPath::HTML.checkbox(locator, xpath_options) }
  failure_message { |node, selector| "no checkbox with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:select) do
  xpath { |locator, xpath_options| XPath::HTML.select(locator, xpath_options) }
  failure_message { |node, selector| "no select box with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:option) do
  xpath { |locator| XPath::HTML.option(locator) }
  failure_message do |node, selector|
    "no option with text '#{selector.locator}'".tap do |message|
      message << " in the select box" if node.tag_name == 'select'
    end
  end
end

Capybara.add_selector(:file_field) do
  xpath { |locator, xpath_options| XPath::HTML.file_field(locator, xpath_options) }
  failure_message { |node, selector| "no file field with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:content) do
  xpath { |content| XPath::HTML.content(content) }
end

Capybara.add_selector(:table) do
  xpath { |locator, xpath_options| XPath::HTML.table(locator, xpath_options) }
end
