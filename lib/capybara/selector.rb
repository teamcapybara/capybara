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
      @xpath = XPath.instance_eval(&block) if block
      @xpath
    end

    # Same as xpath, but wrap in XPath.css().
    def css(&block)
      if block
        @xpath = xpath { |*args| XPath.css(block.call(*args)) }
      end
      @xpath
    end

    def select(&block)
      @select = block if block
      @select
    end

    def default_filter(&block)
      @default_filter = Filter.new(:default, &block) if block
      @default_filter
    end

    def label(label=nil)
      @label = label if label
      @label
    end

    def select?(locator)
      @select and @select.call(locator)
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
  default_filter do
    compile do |_, value|
      if value.is_a?(XPath::Expression)
        value
      else
        XPath::Expression.new(:literal, XPath::Literal.new(value.to_s))
      end
    end
  end
end

Capybara.add_selector(:css) do
  default_filter do
    compile do |_, value|
      css(value)
    end
  end
end

Capybara.add_selector(:id) do
  default_filter do
    compile do |_, value|
      descendant[attr(:id) == value.to_s]
    end
  end
end

Capybara.add_selector(:field) do
  default_filter do
    compile { |xpath, locator| XPath::HTML.field(locator) }
  end
  filter(:label) do
    match do |node, value|
      node.document.first(xpath: "ancestors::label", text: value) or
      node.document.first(for: node[:id], text: value)
    end
    compile do |xpath, value|
      xpath[attr(:id).equals(anywhere(:label)[string.n.contains(value)].attr(:for))] +
      descendant(:label)[string.n.contains(value)].descendant(xpath)
    end
  end
  filter(:disabled) do
    match   { |node, value| value ^ node.disabled? }
    compile { |xpath, value| if value then xpath[attr(:disabled)] else xpath[~attr(:disabled)] end }
  end
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
  xpath { descendant(:fieldset) }
  default_filter do
    compile { |xpath, locator| XPath::HTML.fieldset(locator) }
  end
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  default_filter do
    compile { |xpath, locator| XPath::HTML.link_or_button(locator) }
  end
end

Capybara.add_selector(:link) do
  xpath { descendant(:a)[attr(:href)] }
  default_filter do
    compile { |xpath, locator| XPath::HTML.link(locator) }
  end
  filter(:href) do
    match do |node, href|
      node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)])
    end
  end
end

Capybara.add_selector(:button) do
  default_filter do
    compile { |xpath, locator| XPath::HTML.button(locator) }
  end
end

Capybara.add_selector(:fillable_field) do
  label "field"
  default_filter do
    compile { |xpath, locator| XPath::HTML.fillable_field(locator) }
  end
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  default_filter do
    compile { |xpath, locator| XPath::HTML.radio_button(locator) }
  end
  filter(:checked) do
    match { |node, value| not(value ^ node.checked?) }
  end
  filter(:unchecked) do
    match { |node, value| (value ^ node.checked?) }
  end
end

Capybara.add_selector(:checkbox) do
  default_filter do
    compile { |xpath, locator| XPath::HTML.checkbox(locator) }
  end
  filter(:checked) do
    match { |node, value| not(value ^ node.checked?) }
  end
  filter(:unchecked) do
    match { |node, value| (value ^ node.checked?) }
  end
end

Capybara.add_selector(:select) do
  label "select box"
  default_filter do
    compile { |xpath, locator| XPath::HTML.select(locator) }
  end
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
  default_filter do
    compile { |xpath, locator| XPath::HTML.option(locator) }
  end
end

Capybara.add_selector(:file_field) do
  label "file field"
  default_filter do
    compile { |xpath, locator| XPath::HTML.file_field(locator) }
  end
end

Capybara.add_selector(:table) do
  default_filter do
    compile { |xpath, locator| XPath::HTML.table(locator) }
  end
end
