module Capybara
  class Selector
    attr_reader :name

    class << self
      def all
        @all ||= {}
      end

      def add(name, &block)
        all[name.to_sym] = new(name.to_sym, &block)
      end

      def remove(name)
        all.delete(name.to_sym)
      end
    end

    def initialize(name, &block)
      @name = name
      @custom_filters = {}
      @match = nil
      @label = nil
      @failure_message = nil
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

    def label(label=nil)
      @label = label if label
      @label
    end

    def call(locator)
      @xpath.call(locator)
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, &block)
      @custom_filters[name] = Filter.new(name, &block)
    end

    def filters
      Capybara::Filter.all.merge(@custom_filters)
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
end

Capybara.add_selector(:field) do
  xpath { |locator| XPath::HTML.field(locator) }
  filter(:checked) do
    match { |node, value| not(value ^ node.checked?) }
  end
  filter(:unchecked) do
    match { |node, value| (value ^ node.checked?) }
  end
  filter(:with) do
    match { |node, with| node.value == with }
  end
  filter(:type) do
    match { |node, type| node[:type] == type }
  end
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath { |locator| XPath::HTML.link_or_button(locator) }
end

Capybara.add_selector(:link) do
  xpath { |locator| XPath::HTML.link(locator) }
  filter(:href) do
    match do |node, href|
      node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)])
    end
  end
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
end

Capybara.add_selector(:fillable_field) do
  label "field"
  xpath { |locator| XPath::HTML.fillable_field(locator) }
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath { |locator| XPath::HTML.radio_button(locator) }
  filter(:checked) do
    match { |node, value| not(value ^ node.checked?) }
  end
  filter(:unchecked) do
    match { |node, value| (value ^ node.checked?) }
  end
end

Capybara.add_selector(:checkbox) do
  xpath { |locator| XPath::HTML.checkbox(locator) }
  filter(:checked) do
    match { |node, value| not(value ^ node.checked?) }
  end
  filter(:unchecked) do
    match { |node, value| (value ^ node.checked?) }
  end
end

Capybara.add_selector(:select) do
  label "select box"
  xpath { |locator| XPath::HTML.select(locator) }
  filter(:options) do
    match do |node, options|
      actual = node.all(:xpath, './/option').map { |option| option.text }
      options.sort == actual.sort
    end
  end
  filter(:with_options) do
    match { |node, options| options.all? { |option| node.first(:option, option) } }
  end
  filter(:selected) do
    match do |node, selected|
      actual = node.all(:xpath, './/option').select { |option| option.selected? }.map { |option| option.text }
      [selected].flatten.sort == actual.sort
    end
  end
end

Capybara.add_selector(:option) do
  xpath { |locator| XPath::HTML.option(locator) }
end

Capybara.add_selector(:file_field) do
  label "file field"
  xpath { |locator| XPath::HTML.file_field(locator) }
end

Capybara.add_selector(:content) do
  xpath { |content| XPath::HTML.content(content) }
end

Capybara.add_selector(:table) do
  xpath { |locator| XPath::HTML.table(locator) }
end
