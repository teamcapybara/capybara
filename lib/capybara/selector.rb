module Capybara
  class Selector
    attr_reader :name, :custom_filters


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

    def call(locator)
      @xpath.call(locator)
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
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
  filter(:with) { |node, with| node.value == with }
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  xpath { |locator| XPath::HTML.link_or_button(locator) }
  failure_message { |node, selector| "no link or button '#{selector.locator}' found" }
end

Capybara.add_selector(:link) do
  xpath { |locator| XPath::HTML.link(locator) }
  failure_message { |node, selector| "no link with title, id or text '#{selector.locator}' found" }
  filter(:href) do |node, href|
    node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href)])
  end
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
  failure_message { |node, selector| "no button with value or id or text '#{selector.locator}' found" }
end

Capybara.add_selector(:fillable_field) do
  xpath { |locator| XPath::HTML.fillable_field(locator) }
  failure_message { |node, selector| "no text field, text area or password field with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:radio_button) do
  xpath { |locator| XPath::HTML.radio_button(locator) }
  failure_message { |node, selector| "no radio button with id, name, or label '#{selector.locator}' found" }
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
end

Capybara.add_selector(:checkbox) do
  xpath { |locator| XPath::HTML.checkbox(locator) }
  failure_message { |node, selector| "no checkbox with id, name, or label '#{selector.locator}' found" }
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
end

Capybara.add_selector(:select) do
  xpath { |locator| XPath::HTML.select(locator) }
  failure_message { |node, selector| "no select box with id, name, or label '#{selector.locator}' found" }
  filter(:options) { |node, options| options.all? { |option| node.first(:option, option) } }
  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option').select { |option| option.selected? }.map { |option| option.text }
    ([selected].flatten - actual).empty?
  end
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
  xpath { |locator| XPath::HTML.file_field(locator) }
  failure_message { |node, selector| "no file field with id, name, or label '#{selector.locator}' found" }
end

Capybara.add_selector(:content) do
  xpath { |content| XPath::HTML.content(content) }
end

Capybara.add_selector(:table) do
  xpath { |locator| XPath::HTML.table(locator) }
end
