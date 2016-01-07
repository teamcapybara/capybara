module Capybara
  class Selector
    class Filter
      def initialize(name, block, options={})
        @name = name
        @block = block
        @options = options
        @options[:valid_values] = [true,false] if options[:boolean]
      end

      def default?
        @options.has_key?(:default)
      end

      def default
        @options[:default]
      end

      def matches?(node, value)
        return true if skip?(value)

        if @options.has_key?(:valid_values) && !Array(@options[:valid_values]).include?(value)
          msg = "Invalid value #{value.inspect} passed to filter #{@name} - "
          if default?
            warn msg + "defaulting to #{default}"
            value = default
          else
            warn msg + "skipping"
            return true
          end
        end

        @block.call(node, value)
      end

      def skip?(value)
        @options.has_key?(:skip_if) && value == @options[:skip_if]
      end
    end

    attr_reader :name, :custom_filters, :format

    class << self
      def all
        @selectors ||= {}
      end

      def add(name, &block)
        all[name.to_sym] = Capybara::Selector.new(name.to_sym, &block)
      end

      def update(name, &block)
        all[name.to_sym].instance_eval(&block)
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
      @description = nil
      instance_eval(&block)
    end

    def xpath(&block)
      if block
        @format = :xpath
        @xpath, @css = block, nil
      end
      @xpath
    end

    # Same as xpath, but wrap in XPath.css().
    def css(&block)
      if block
        @format = :css
        @css, @xpath = block, nil
      end
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

    def description(options={})
      (@description && @description.call(options)).to_s
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

    def describe &block
      @description = block
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
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  filter(:readonly, boolean: true) { |node, value| not(value ^ node[:readonly]) }
  filter(:with) { |node, with| node.value == with.to_s }
  filter(:type) do |node, type|
    if ['textarea', 'select'].include?(type)
      node.tag_name == type
    else
      node[:type] == type
    end
  end
  describe do |options|
    desc, states = "", []
    desc << " of type #{options[:type].inspect}" if options[:type]
    desc << " with value #{options[:with].to_s.inspect}" if options.has_key?(:with)
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath { |locator| XPath::HTML.link_or_button(locator) }
  filter(:disabled, default: false, boolean: true) { |node, value| node.tag_name == "a" or not(value ^ node.disabled?) }
  describe { |options| " that is disabled" if options[:disabled] }
end

Capybara.add_selector(:link) do
  xpath { |locator| XPath::HTML.link(locator) }
  filter(:href) do |node, href|
    if href.is_a? Regexp
      node[:href].match href
    else
      node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)], minimum: 0)
    end
  end
  describe { |options| " with href #{options[:href].inspect}" if options[:href] }
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe { |options| " that is disabled" if options[:disabled] == true }
end

Capybara.add_selector(:fillable_field) do
  label "field"
  xpath { |locator| XPath::HTML.fillable_field(locator) }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe { |options| " that is disabled" if options[:disabled] == true }
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath { |locator| XPath::HTML.radio_button(locator) }
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc, states = "", []
    desc << " with value #{options[:option].inspect}" if options[:option]
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.add_selector(:checkbox) do
  xpath { |locator| XPath::HTML.checkbox(locator) }
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc, states = "", []
    desc << " with value #{options[:option].inspect}" if options[:option]
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.add_selector(:select) do
  label "select box"
  xpath { |locator| XPath::HTML.select(locator) }
  filter(:options) do |node, options|
    if node.visible?
      actual = node.all(:xpath, './/option').map { |option| option.text }
    else
      actual = node.all(:xpath, './/option', visible: false).map { |option| option.text(:all) }
    end
    options.sort == actual.sort
  end
  filter(:with_options) do |node, options|
    finder_settings = { minimum: 0 }
    if !node.visible?
      finder_settings[:visible] = false
    end
    options.all? { |option| node.first(:option, option, finder_settings) }
  end
  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false).select { |option| option.selected? }.map { |option| option.text(:all) }
    [selected].flatten.sort == actual.sort
  end
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc = ""
    desc << " with options #{options[:options].inspect}" if options[:options]
    desc << " with at least options #{options[:with_options].inspect}" if options[:with_options]
    desc << " with #{options[:selected].inspect} selected" if options[:selected]
    desc << " that is disabled" if options[:disabled] == true
    desc
  end
end

Capybara.add_selector(:option) do
  xpath { |locator| XPath::HTML.option(locator) }
end

Capybara.add_selector(:file_field) do
  label "file field"
  xpath { |locator| XPath::HTML.file_field(locator) }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  describe { |options| " that is disabled" if options[:disabled] == true}
end

Capybara.add_selector(:table) do
  xpath { |locator| XPath::HTML.table(locator) }
end
