# frozen_string_literal: true
require 'capybara/selector/selector'

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
  xpath do |locator|
    xpath = XPath.descendant(:input, :textarea, :select)[~XPath.attr(:type).one_of('submit', 'image', 'hidden')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end
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
  filter(:multiple, boolean: true) { |node, value| !(value ^ node[:multiple]) }
  describe do |options|
    desc, states = String.new, []
    desc << " of type #{options[:type].inspect}" if options[:type]
    desc << " with value #{options[:with].to_s.inspect}" if options.has_key?(:with)
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc << " with the multiple attribute" if options[:multiple] == true
    desc << " without the multiple attribute" if options[:multiple] === false
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
      xpath = xpath[XPath.attr(:id).equals(locator) |
                    XPath.string.n.is(locator) |
                    XPath.attr(:title).is(locator) |
                    XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]
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
      input_btn_xpath = input_btn_xpath[XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)]
      btn_xpath = btn_xpath[XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.string.n.is(locator) | XPath.attr(:title).is(locator)]
      image_btn_xpath = image_btn_xpath[XPath.attr(:alt).is(locator)]
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

  filter(:disabled, default: false, boolean: true) { |node, value| node.tag_name == "a" or not(value ^ node.disabled?) }

  describe { |options| " that is disabled" if options[:disabled] }
end

Capybara.add_selector(:fillable_field) do
  label "field"
  xpath do |locator|
    xpath = XPath.descendant(:input, :textarea)[~XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  filter(:multiple, boolean: true) { |node, value| !(value ^ node[:multiple]) }

  describe do |options|
    desc = String.new
    desc << " that is disabled" if options[:disabled] == true
    desc << " with the multiple attribute" if options[:multiple] == true
    desc << " without the multiple attribute" if options[:multiple] === false
    desc
  end
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath do |locator|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('radio')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }

  describe do |options|
    desc, states = String.new, []
    desc << " with value #{options[:option].inspect}" if options[:option]
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.add_selector(:checkbox) do
  xpath do |locator|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('checkbox')]
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }

  describe do |options|
    desc, states = String.new, []
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
  xpath do |locator|
    xpath = XPath.descendant(:select)
    xpath = locate_field(xpath, locator.to_s) unless locator.nil?
    xpath
  end

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
  filter(:multiple, boolean: true) { |node, value| !(value ^ node[:multiple]) }

  describe do |options|
    desc = String.new
    desc << " with options #{options[:options].inspect}" if options[:options]
    desc << " with at least options #{options[:with_options].inspect}" if options[:with_options]
    desc << " with #{options[:selected].inspect} selected" if options[:selected]
    desc << " that is disabled" if options[:disabled] == true
    desc << " that allows multiple selection" if options[:multiple] == true
    desc << " that only allows single selection" if options[:multiple] === false
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

  filter(:disabled, default: false, boolean: true, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  filter(:multiple, boolean: true) { |node, value| !(value ^ node[:multiple]) }

  describe do |options|
    desc = String.new
    desc << " that is disabled" if options[:disabled] == true
    desc << " that allows multiple files" if options[:multiple] == true
    desc << " that only allows a single file" if options[:multiple] === false
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

Capybara.add_selector(:label) do
  dynamic do |locator|
    Proc.new do |ctx_node, exact|
      exact = exact ? :exact : nil
      if locator.is_a? Capybara::Node::Element
        nodes = locator.find_xpath('ancestor::label[not(@for)][1]')
        if locator[:id]
          selector = XPath.descendant(:label)[XPath.attr(:for).equals(locator[:id])]
          nodes += ctx_node.find_xpath(selector.to_xpath(exact))
        end
        nodes
      else
        selector = XPath.descendant(:label)[XPath.attr(:for).equals(locator.to_s) | XPath.string.n.is(locator.to_s)]
        ctx_node.find_xpath(selector.to_xpath(exact))
      end
    end
  end
end
