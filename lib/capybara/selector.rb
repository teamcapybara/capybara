# frozen_string_literal: true

require 'capybara/selector/selector'
Capybara::Selector::FilterSet.add(:_field) do
  filter(:checked, :boolean) { |node, value| !(value ^ node.checked?) }
  filter(:unchecked, :boolean) { |node, value| (value ^ node.checked?) }
  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }
  filter(:multiple, :boolean) { |node, value| !(value ^ node.multiple?) }

  expression_filter(:name) { |xpath, val| xpath[XPath.attr(:name) == val] }
  expression_filter(:placeholder) { |xpath, val| xpath[XPath.attr(:placeholder) == val] }

  describe do |checked: nil, unchecked: nil, disabled: nil, multiple: nil, **_options|
    desc, states = "".dup, []
    states << 'checked' if checked || (unchecked == false)
    states << 'not checked' if unchecked || (checked == false)
    states << 'disabled' if disabled == true
    states << 'not disabled' if disabled == false
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc << " with the multiple attribute" if multiple == true
    desc << " without the multiple attribute" if multiple == false
    desc
  end
end

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ParameterLists

##
#
# Select elements by XPath expression
#
# @locator An XPath expression
#
Capybara.add_selector(:xpath) do
  xpath { |xpath| xpath }
end

##
#
# Select elements by CSS selector
#
# @locator A CSS selector
#
Capybara.add_selector(:css) do
  css { |css| css }
end

##
#
# Select element by id
#
# @locator The id of the element to match
#
Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
end

##
#
# Select field elements (input [not of type submit, image, or hidden], textarea, select)
#
# @locator Matches against the id, name, or placeholder
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String] :placeholder  Matches the placeholder attribute
# @filter [String] :type Matches the type attribute of the field or element type for 'textarea' and 'select'
# @filter [Boolean] :readonly
# @filter [String] :with  Matches the current value of the field
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :checked Match checked fields?
# @filter [Boolean] :unchecked Match unchecked fields?
# @filter [Boolean] :disabled Match disabled field?
# @filter [Boolean] :multiple Match fields that accept multiple values
Capybara.add_selector(:field) do
  xpath do |locator, **options|
    xpath = XPath.descendant(:input, :textarea, :select)[!XPath.attr(:type).one_of('submit', 'image', 'hidden')]
    locate_field(xpath, locator, options)
  end

  expression_filter(:type) do |expr, type|
    type = type.to_s
    if %w[textarea select].include?(type)
      expr.self(type.to_sym)
    else
      expr[XPath.attr(:type) == type]
    end
  end

  filter_set(:_field) # checked/unchecked/disabled/multiple/name/placeholder

  filter(:readonly, :boolean) { |node, value| !(value ^ node.readonly?) }
  filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end
  describe do |type: nil, **options|
    desc = "".dup
    (expression_filters.keys - [:type]).each { |ef| desc << " with #{ef} #{options[ef]}" if options.key?(ef) }
    desc << " of type #{type.inspect}" if type
    desc << " with value #{options[:with].to_s.inspect}" if options.key?(:with)
    desc
  end
end

##
#
# Select fieldset elements
#
# @locator Matches id or contents of wrapped legend
#
# @filter [String] :id Matches id attribute
# @filter [String] :legend Matches contents of wrapped legend
# @filter [String, Array<String>] :class Matches the class(es) provided
#
Capybara.add_selector(:fieldset) do
  xpath(:legend) do |locator, legend: nil, **_options|
    xpath = XPath.descendant(:fieldset)
    xpath = xpath[(XPath.attr(:id) == locator.to_s) | XPath.child(:legend)[XPath.string.n.is(locator.to_s)]] unless locator.nil?
    xpath = xpath[XPath.child(:legend)[XPath.string.n.is(legend)]] if legend
    xpath
  end
end

##
#
# Find links ( <a> elements with an href attribute )
#
# @locator Matches the id or title attributes, or the string content of the link, or the alt attribute of a contained img element
#
# @filter [String] :id  Matches the id attribute
# @filter [String] :title Matches the title attribute
# @filter [String] :alt Matches the alt attribute of a contained img element
# @filter [String] :class Matches the class(es) provided
# @filter [String, Regexp,nil] :href  Matches the normalized href of the link, if nil will find <a> elements with no href attribute
#
Capybara.add_selector(:link) do
  xpath(:title, :alt) do |locator, href: true, enable_aria_label: false, alt: nil, title: nil, **_options|
    xpath = XPath.descendant(:a)
    xpath = xpath[
              case href
              when nil, false
                !XPath.attr(:href)
              when true
                XPath.attr(:href)
              when Regexp
                nil # needs to be handled in filter
              else
                XPath.attr(:href) == href.to_s
              end
            ]

    unless locator.nil?
      locator = locator.to_s
      matchers = [XPath.attr(:id) == locator,
                  XPath.string.n.is(locator),
                  XPath.attr(:title).is(locator),
                  XPath.descendant(:img)[XPath.attr(:alt).is(locator)]].reduce(:|)
      matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      xpath = xpath[matchers]
    end

    xpath = xpath[find_by_attr(:title, title)]
    xpath = xpath[XPath.descendant(:img)[XPath.attr(:alt) == alt]] if alt
    xpath
  end

  filter(:href) do |node, href|
    # If not a Regexp it's been handled in the main XPath
    href.is_a?(Regexp) ? node[:href].match(href) : true
  end

  describe do |**options|
    desc = "".dup
    desc << " with href #{options[:href].inspect}" if options[:href]
    desc << " with no href attribute" if options.fetch(:href, true).nil?
  end
end

##
#
#  Find buttons ( input [of type submit, reset, image, button] or button elements )
#
# @locator Matches the id, value, or title attributes, string content of a button, or the alt attribute of an image type button or of a descendant image of a button
#
# @filter [String] :id  Matches the id attribute
# @filter [String] :title Matches the title attribute
# @filter [String] :class Matches the class(es) provided
# @filter [String] :value Matches the value of an input button
#
Capybara.add_selector(:button) do
  xpath(:value, :title, :type) do |locator, **options|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type) == 'image']

    unless locator.nil?
      locator = locator.to_s
      locator_matches = XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)
      locator_matches |= XPath.attr(:'aria-label').is(locator) if options[:enable_aria_label]

      input_btn_xpath = input_btn_xpath[locator_matches]

      btn_xpath = btn_xpath[locator_matches | XPath.string.n.is(locator) | XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if options[:enable_aria_label]
      image_btn_xpath = image_btn_xpath[alt_matches]
    end

    res_xpath = input_btn_xpath.union(btn_xpath).union(image_btn_xpath)

    res_xpath = expression_filters.keys.inject(res_xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }

    res_xpath
  end

  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  describe do |disabled: nil, **options|
    desc = "".dup
    desc << " that is disabled" if disabled == true
    desc << describe_all_expression_filters(options)
    desc
  end
end

##
#
# Find links or buttons
#
Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath do |locator, **options|
    self.class.all.values_at(:link, :button).map { |selector| selector.xpath.call(locator, options) }.reduce(:union)
  end

  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| node.tag_name == "a" or !(value ^ node.disabled?) }

  describe { |disabled: nil, **_options| " that is disabled" if disabled == true }
end

##
#
# Find text fillable fields ( textarea, input [not of type submit, image, radio, checkbox, hidden, file] )
#
# @locator Matches against the id, name, or placeholder
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String] :placeholder  Matches the placeholder attribute
# @filter [String] :with  Matches the current value of the field
# @filter [String] :type Matches the type attribute of the field or element type for 'textarea'
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :disabled Match disabled field?
# @filter [Boolean] :multiple Match fields that accept multiple values
#
Capybara.add_selector(:fillable_field) do
  label "field"

  xpath do |locator, **options|
    xpath = XPath.descendant(:input, :textarea)[!XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
    locate_field(xpath, locator, options)
  end

  expression_filter(:type) do |expr, type|
    type = type.to_s
    if ['textarea'].include?(type)
      expr.self(type.to_sym)
    else
      expr[XPath.attr(:type) == type]
    end
  end

  filter_set(:_field, %i[disabled multiple name placeholder])

  filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end

  describe do |options|
    desc = "".dup
    desc << describe_all_expression_filters(options)
    desc << " with value #{options[:with].to_s.inspect}" if options.key?(:with)
    desc
  end
end

##
#
# Find radio buttons
#
# @locator Match id, name, or associated label text
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :checked Match checked fields?
# @filter [Boolean] :unchecked Match unchecked fields?
# @filter [Boolean] :disabled Match disabled field?
# @filter [String] :option Match the value
#
Capybara.add_selector(:radio_button) do
  label "radio button"

  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'radio']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[checked unchecked disabled name])

  filter(:option) { |node, value| node.value == value.to_s }

  describe do |option: nil, **options|
    desc = "".dup
    desc << " with value #{option.inspect}" if option
    desc << describe_all_expression_filters(options)
    desc
  end
end

##
#
# Find checkboxes
#
# @locator Match id, name, or associated label text
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :checked Match checked fields?
# @filter [Boolean] :unchecked Match unchecked fields?
# @filter [Boolean] :disabled Match disabled field?
# @filter [String] :option Match the value
#
Capybara.add_selector(:checkbox) do
  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'checkbox']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[checked unchecked disabled name])

  filter(:option) { |node, value| node.value == value.to_s }

  describe do |option: nil, **options|
    desc = "".dup
    desc << " with value #{option.inspect}" if option
    desc << describe_all_expression_filters(options)
    desc
  end
end

##
#
# Find select elements
#
# @locator Match id, name, placeholder, or associated label text
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String] :placeholder  Matches the placeholder attribute
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :disabled Match disabled field?
# @filter [Boolean] :multiple Match fields that accept multiple values
# @filter [Array<String>] :options Exact match options
# @filter [Array<String>] :with_options Partial match options
# @filter [String, Array<String>] :selected Match the selection(s)
# @filter [String, Array<String>] :with_selected Partial match the selection(s)
#
Capybara.add_selector(:select) do
  label "select box"

  xpath do |locator, **options|
    xpath = XPath.descendant(:select)
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled multiple name placeholder])

  filter(:options) do |node, options|
    actual = if node.visible?
      node.all(:xpath, './/option', wait: false).map(&:text)
    else
      node.all(:xpath, './/option', visible: false, wait: false).map { |option| option.text(:all) }
    end
    options.sort == actual.sort
  end

  expression_filter(:with_options) do |expr, options|
    options.each do |option|
      expr = expr[Capybara::Selector.all[:option].call(option)]
    end
    expr
  end

  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
    Array(selected).sort == actual.sort
  end

  filter(:with_selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
    (Array(selected) - actual).empty?
  end

  describe do |options: nil, with_options: nil, selected: nil, with_selected: nil, **opts|
    desc = "".dup
    desc << " with options #{options.inspect}" if options
    desc << " with at least options #{with_options.inspect}" if with_options
    desc << " with #{selected.inspect} selected" if selected
    desc << " with at least #{with_selected.inspect} selected" if with_selected
    desc << describe_all_expression_filters(opts)
    desc
  end
end

Capybara.add_selector(:datalist_input) do
  label "input box with datalist completion"

  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:list)]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled name placeholder])

  filter(:options) do |node, options|
    actual = node.find("//datalist[@id=#{node[:list]}]", visible: :all).all(:datalist_option, wait: false).map(&:value)
    options.sort == actual.sort
  end

  expression_filter(:with_options) do |expr, options|
    options.each do |option|
      expr = expr[XPath.attr(:list) == XPath.anywhere(:datalist)[Capybara::Selector.all[:datalist_option].call(option)].attr(:id)]
    end
    expr
  end

  describe do |options: nil, with_options: nil, **opts|
    desc = "".dup
    desc << " with options #{options.inspect}" if options
    desc << " with at least options #{with_options.inspect}" if with_options
    desc << describe_all_expression_filters(opts)
    desc
  end
end

##
#
# Find option elements
#
# @locator Match text of option
# @filter [Boolean] :disabled Match disabled option
# @filter [Boolean] :selected Match selected option
#
Capybara.add_selector(:option) do
  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
  filter(:selected, :boolean) { |node, value| !(value ^ node.selected?) }

  describe do |**options|
    desc = "".dup
    desc << " that is#{' not' unless options[:disabled]} disabled" if options.key?(:disabled)
    desc << " that is#{' not' unless options[:selected]} selected" if options.key?(:selected)
    desc
  end
end

Capybara.add_selector(:datalist_option) do
  label "datalist option"
  visible(:all)

  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s) | (XPath.attr(:value) == locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }

  describe do |**options|
    desc = "".dup
    desc << " that is#{' not' unless options[:disabled]} disabled" if options.key?(:disabled)
    desc
  end
end

##
#
# Find file input elements
#
# @locator Match id, name, or associated label text
# @filter [String] :id  Matches the id attribute
# @filter [String] :name  Matches the name attribute
# @filter [String, Array<String>] :class  Matches the class(es) provided
# @filter [Boolean] :disabled Match disabled field?
# @filter [Boolean] :multiple Match field that accepts multiple values
#
Capybara.add_selector(:file_field) do
  label "file field"
  xpath do |locator, options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'file']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled multiple name])

  describe do |**options|
    desc = "".dup
    desc << describe_all_expression_filters(options)
    desc
  end
end

##
#
# Find label elements
#
# @locator Match id or text contents
# @filter [Element, String] :for The element or id of the element associated with the label
#
Capybara.add_selector(:label) do
  label "label"
  xpath(:for) do |locator, options|
    xpath = XPath.descendant(:label)
    xpath = xpath[XPath.string.n.is(locator.to_s) | (XPath.attr(:id) == locator.to_s)] unless locator.nil?
    if options.key?(:for) && !options[:for].is_a?(Capybara::Node::Element)
      with_attr = XPath.attr(:for) == options[:for].to_s
      labelable_elements = %i[button input keygen meter output progress select textarea]
      wrapped = !XPath.attr(:for) &
                XPath.descendant(*labelable_elements)[XPath.attr(:id) == options[:for].to_s]
      xpath = xpath[with_attr | wrapped]
    end
    xpath
  end

  filter(:for) do |node, field_or_value|
    if field_or_value.is_a? Capybara::Node::Element
      if node[:for]
        field_or_value[:id] == node[:for]
      else
        field_or_value.find_xpath('./ancestor::label[1]').include? node.base
      end
    else
      # Non element values were handled through the expression filter
      true
    end
  end

  describe do |**options|
    desc = "".dup
    desc << " for #{options[:for]}" if options[:for]
    desc
  end
end

##
#
# Find table elements
#
# @locator id or caption text of table
# @filter [String] :id Match id attribute of table
# @filter [String] :caption Match text of associated caption
# @filter [String, Array<String>] :class  Matches the class(es) provided
#
Capybara.add_selector(:table) do
  xpath(:caption) do |locator, options|
    xpath = XPath.descendant(:table)
    xpath = xpath[(XPath.attr(:id) == locator.to_s) | XPath.descendant(:caption).is(locator.to_s)] unless locator.nil?
    xpath = xpath[XPath.descendant(:caption) == options[:caption]] if options[:caption]
    xpath
  end

  describe do |caption: nil, **_options|
    desc = "".dup
    desc << " with caption #{caption}" if caption
    desc
  end
end

##
#
# Find frame/iframe elements
#
# @locator Match id or name
# @filter [String] :id Match id attribute
# @filter [String] :name Match name attribute
# @filter [String, Array<String>] :class  Matches the class(es) provided
#
Capybara.add_selector(:frame) do
  xpath(:name) do |locator, **options|
    xpath = XPath.descendant(:iframe).union(XPath.descendant(:frame))
    xpath = xpath[(XPath.attr(:id) == locator.to_s) | (XPath.attr(:name) == locator.to_s)] unless locator.nil?
    xpath = expression_filters.keys.inject(xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }
    xpath
  end

  describe do |name: nil, **_options|
    desc = "".dup
    desc << " with name #{name}" if name
    desc
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ParameterLists
