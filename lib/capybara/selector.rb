module Capybara
  class Selector
    ONLY_DISABLED_FIELDS = XPath.attr(:disabled) | (XPath::Expression.new(:literal, :'ancestor::fieldset[@disabled]') & ~XPath::Expression.new(:literal, :'ancestor::legend[not(preceding-sibling::legend)]') )
    NO_DISABLED_FIELDS   = ~XPath.attr(:disabled) & (~XPath::Expression.new(:literal, :'ancestor::fieldset[@disabled]') | XPath::Expression.new(:literal, :'ancestor::legend[not(preceding-sibling::legend)]') )
    
    class Filter
      def initialize(name, block, options={})
        @name = name
        @block = block
        @options = options
      end

      def default?
        @options.has_key?(:default)
      end

      def default
        @options[:default]
      end

      def matches?(node, value)
        @block.call(node, value)
      end
    end
    
    class Modifier < Filter
      def modify(query, value)
        @block.call(query, value)
      end
    end
      
    attr_reader :name, :custom_filters, :custom_modifiers, :format

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
      @custom_modifiers = {}
      @match = nil
      @label = nil
      @failure_message = nil
      instance_eval(&block)
    end

    def xpath(&block)
      @format = :xpath
      @xpath = block if block
      @xpath
    end

    # Same as xpath, but wrap in XPath.css().
    def css(&block)
      @format = :css
      @css = block if block
      @css
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
      if @format==:css
        @css.call(locator)
      else
        @xpath.call(locator)
      end
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, options={}, &block)
      @custom_filters[name] = Filter.new(name, block, options)
    end
    
    def modifier(name, options={}, &block)
      @custom_modifiers[name] = Modifier.new(name, block, options)
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
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
  filter(:with) { |node, with| node.value == with }
  filter(:type) do |node, type|
    if ['textarea', 'select'].include?(type)
      node.tag_name == type
    else
      node[:type] == type
    end
  end
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath { |locator| XPath::HTML.link_or_button(locator) }
  modifier(:disabled, :default => false) { |query, value| 
    if value
      query.expressions[0] + query.expressions[1][Capybara::Selector::ONLY_DISABLED_FIELDS]
    else
      query.expressions[0] + query.expressions[1][Capybara::Selector::NO_DISABLED_FIELDS]
    end 
  }
end

Capybara.add_selector(:link) do
  xpath { |locator| XPath::HTML.link(locator) }
  filter(:href) do |node, href|
    node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)])
  end
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end


Capybara.add_selector(:fillable_field) do
  label "field"
  xpath { |locator| XPath::HTML.fillable_field(locator) }
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath { |locator| XPath::HTML.radio_button(locator) }
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:checkbox) do
  xpath { |locator| XPath::HTML.checkbox(locator) }
  filter(:checked) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked) { |node, value| (value ^ node.checked?) }
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:select) do
  label "select box"
  xpath { |locator| XPath::HTML.select(locator) }
  filter(:options) do |node, options|
    actual = node.all(:xpath, './/option').map { |option| option.text }
    options.sort == actual.sort
  end
  filter(:with_options) { |node, options| options.all? { |option| node.first(:option, option) } }
  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option').select { |option| option.selected? }.map { |option| option.text }
    [selected].flatten.sort == actual.sort
  end
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:option) do
  xpath { |locator| XPath::HTML.option(locator) }
end

Capybara.add_selector(:file_field) do
  label "file field"
  xpath { |locator| XPath::HTML.file_field(locator) }
  modifier(:disabled, :default => false) { |query, value| value ? query[Capybara::Selector::ONLY_DISABLED_FIELDS] : query[Capybara::Selector::NO_DISABLED_FIELDS] }
end

Capybara.add_selector(:table) do
  xpath { |locator| XPath::HTML.table(locator) }
end
