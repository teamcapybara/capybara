# frozen_string_literal: true
require 'capybara/selector/filter_set'

module Capybara
  class Selector

    attr_reader :name, :format

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
      @filter_set = FilterSet.add(name){}
      @match = nil
      @label = nil
      @failure_message = nil
      @description = nil
      @format = nil
      @expression = nil
      instance_eval(&block)
    end

    def custom_filters
      @filter_set.filters
    end

    def xpath(&block)
      @format, @expression = :xpath, block if block
      format == :xpath ? @expression : nil
    end

    def css(&block)
      @format, @expression = :css, block if block
      format == :css ? @expression : nil
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
      @filter_set.description(options)
    end

    def call(locator)
      if format
        @expression.call(locator)
      else
        warn "Selector has no format"
      end
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, options={}, &block)
      custom_filters[name] = Filter.new(name, block, options)
    end

    def filter_set(name, filters_to_use = nil)
      f_set = FilterSet.all[name]
      f_set.filters.each do | name, filter |
        custom_filters[name] = filter if filters_to_use.nil? || filters_to_use.include?(name)
      end
      f_set.descriptions.each { |desc| @filter_set.describe &desc }
    end

    def describe &block
      @filter_set.describe &block
    end

    private

    def locate_field(xpath, locator)
      attr_matchers =  XPath.attr(:id).equals(locator) |
                       XPath.attr(:name).equals(locator) |
                       XPath.attr(:placeholder).equals(locator) |
                       XPath.attr(:id).equals(XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for))
      attr_matchers |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label

      locate_field = xpath[attr_matchers]
      locate_field += XPath.descendant(:label)[XPath.string.n.is(locator)].descendant(xpath)
      locate_field
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

Capybara::Selector::FilterSet.add(:_field) do
  filter(:id) { |node, id| node['id'] == id }
  filter(:name) { |node, name| node['name'] == name }
  filter(:placeholder) { |node, placeholder| node['placeholder'] == placeholder }
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  filter(:multiple, boolean: true) { |node, value| !(value ^ node.multiple?) }

  describe do |options|
    desc, states = String.new, []
    [:id, :name, :placeholder].each do |opt|
      desc << " with #{opt.to_s} #{options[opt]}" if options.has_key?(opt)
    end
    states << 'checked' if options[:checked] || (options[:unchecked] === false)
    states << 'not checked' if options[:unchecked] || (options[:checked] === false)
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc << " with the multiple attribute" if options[:multiple] == true
    desc << " without the multiple attribute" if options[:multiple] === false
    desc
  end
end

Capybara.add_selector(:field) do
  xpath do |locator|
    xpath = XPath.descendant(:input, :textarea, :select)[~XPath.attr(:type).one_of('submit', 'image', 'hidden')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field)

  filter(:readonly, boolean: true) { |node, value| not(value ^ node.readonly?) }
  filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end
  filter(:type) do |node, type|
    type = type.to_s
    if ['textarea', 'select'].include?(type)
      node.tag_name == type
    else
      node[:type] == type
    end
  end
  describe do |options|
    desc, states = String.new, []
    desc << " of type #{options[:type].inspect}" if options[:type]
    desc << " with value #{options[:with].to_s.inspect}" if options.has_key?(:with)
    desc
  end
end

Capybara.add_selector(:fieldset) do
  xpath do |locator|
    xpath = XPath.descendant(:fieldset)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.child(:legend)[XPath.string.n.is(locator.to_s)]] unless locator.nil?
    xpath
  end
end

Capybara.add_selector(:link) do
  xpath do |locator|
    xpath = XPath.descendant(:a)[XPath.attr(:href)]
    unless locator.nil?
      locator = locator.to_s
      matchers = XPath.attr(:id).equals(locator) |
                 XPath.string.n.is(locator) |
                 XPath.attr(:title).is(locator) |
                 XPath.descendant(:img)[XPath.attr(:alt).is(locator)]
      matchers |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label
      xpath = xpath[matchers]
    end
    xpath
  end

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
  xpath do |locator|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).equals('image')]

    unless locator.nil?
      locator = locator.to_s
      locator_matches = XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)
      locator_matches |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label

      input_btn_xpath = input_btn_xpath[locator_matches]

      btn_xpath = btn_xpath[locator_matches | XPath.string.n.is(locator)]

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label
      image_btn_xpath = image_btn_xpath[alt_matches]
    end

    input_btn_xpath + btn_xpath + image_btn_xpath
  end

  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }

  describe { |options| " that is disabled" if options[:disabled] == true }
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath do |locator|
    self.class.all.values_at(:link, :button).map {|selector| selector.xpath.call(locator)}.reduce(:+)
  end

  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| node.tag_name == "a" or not(value ^ node.disabled?) }

  describe { |options| " that is disabled" if options[:disabled] }
end

Capybara.add_selector(:fillable_field) do
  label "field"
  xpath do |locator|
    xpath = XPath.descendant(:input, :textarea)[~XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field, [:id, :name, :placeholder, :disabled, :multiple])
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath do |locator|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('radio')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field, [:id, :name, :checked, :unchecked, :disabled])

  filter(:option)  { |node, value|  node.value == value.to_s }

  describe do |options|
    desc = String.new
    desc << " with value #{options[:option].inspect}" if options[:option]
    desc
  end
end

Capybara.add_selector(:checkbox) do
  xpath do |locator|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('checkbox')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field, [:id, :name, :checked, :unchecked, :disabled])

  filter(:option)  { |node, value|  node.value == value.to_s }

  describe do |options|
    desc = String.new
    desc << " with value #{options[:option].inspect}" if options[:option]
    desc
  end
end

Capybara.add_selector(:select) do
  label "select box"
  xpath do |locator|
    xpath = XPath.descendant(:select)
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field, [:id, :name, :placeholder, :disabled, :multiple])

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

  describe do |options|
    desc = String.new
    desc << " with options #{options[:options].inspect}" if options[:options]
    desc << " with at least options #{options[:with_options].inspect}" if options[:with_options]
    desc << " with #{options[:selected].inspect} selected" if options[:selected]
    desc
  end
end

Capybara.add_selector(:option) do
  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:disabled, boolean: true) { |node, value| not(value ^ node.disabled?) }
  filter(:selected, boolean: true) { |node, value| not(value ^ node.selected?) }

  describe do |options|
    desc = String.new
    desc << " that is#{' not' unless options[:disabled]} disabled" if options.has_key?(:disabled)
    desc << " that is#{' not' unless options[:selected]} selected" if options.has_key?(:selected)
    desc
  end
end

Capybara.add_selector(:file_field) do
  label "file field"
  xpath do |locator|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('file')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter_set(:_field, [:id, :name, :disabled, :multiple])
end

Capybara.add_selector(:label) do
  label "label"
  xpath do |locator|
    xpath = XPath.descendant(:label)
    xpath = xpath[XPath.string.n.is(locator.to_s) | XPath.attr(:id).equals(locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:for) do |node, field_or_value|
    if field_or_value.is_a? Capybara::Node::Element
      if field_or_value[:id] && (field_or_value[:id] == node[:for])
        true
      else
        field_or_value.find_xpath('./ancestor::label[1]').include? node.base
      end
    else
      node[:for] == field_or_value.to_s
    end
  end

  describe do |options|
    desc = String.new
    desc << " for #{options[:for]}" if options[:for]
    desc
  end
end

Capybara.add_selector(:table) do
  xpath do |locator|
    xpath = XPath.descendant(:table)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.descendant(:caption).is(locator.to_s)] unless locator.nil?
    xpath
  end
end

Capybara.add_selector(:frame) do
  xpath do |locator|
    xpath = XPath.descendant(:iframe) + XPath.descendant(:frame)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.attr(:name).equals(locator)] unless locator.nil?
    xpath
  end
end
