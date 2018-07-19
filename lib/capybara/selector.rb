# frozen_string_literal: true

require 'capybara/selector/selector'
Capybara::Selector::FilterSet.add(:_field) do
  node_filter(:checked, :boolean) { |node, value| !(value ^ node.checked?) }
  node_filter(:unchecked, :boolean) { |node, value| (value ^ node.checked?) }
  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }
  node_filter(:multiple, :boolean) { |node, value| !(value ^ node.multiple?) }

  expression_filter(:name) { |xpath, val| xpath[XPath.attr(:name) == val] }
  expression_filter(:placeholder) { |xpath, val| xpath[XPath.attr(:placeholder) == val] }

  describe(:node_filters) do |checked: nil, unchecked: nil, disabled: nil, multiple: nil, **|
    desc, states = +'', []
    states << 'checked' if checked || (unchecked == false)
    states << 'not checked' if unchecked || (checked == false)
    states << 'disabled' if disabled == true
    states << 'not disabled' if disabled == false
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc << ' with the multiple attribute' if multiple == true
    desc << ' without the multiple attribute' if multiple == false
    desc
  end
end

# rubocop:disable Metrics/BlockLength

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

  node_filter(:readonly, :boolean) { |node, value| !(value ^ node.readonly?) }
  node_filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end

  describe_expression_filters do |type: nil, **options|
    desc = +''
    (expression_filters.keys - [:type]).each { |ef| desc << " with #{ef} #{options[ef]}" if options.key?(ef) }
    desc << " of type #{type.inspect}" if type
    desc
  end

  describe_node_filters do |**options|
    " with value #{options[:with].to_s.inspect}" if options.key?(:with)
  end
end

Capybara.add_selector(:fieldset) do
  xpath(:legend) do |locator, legend: nil, **|
    locator_matchers = (XPath.attr(:id) == locator.to_s) | XPath.child(:legend)[XPath.string.n.is(locator.to_s)]
    locator_matchers |= XPath.attr(test_id) == locator if test_id
    xpath = XPath.descendant(:fieldset)
    xpath = xpath[locator_matchers] unless locator.nil?
    xpath = xpath[XPath.child(:legend)[XPath.string.n.is(legend)]] if legend
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
end

Capybara.add_selector(:link) do
  xpath(:title, :alt) do |locator, href: true, alt: nil, title: nil, **|
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
                  XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]
      matchers << XPath.attr(:'aria-label').is(locator) if enable_aria_label
      matchers << XPath.attr(test_id) == locator if test_id
      xpath = xpath[matchers.reduce(:|)]
    end

    xpath = xpath[find_by_attr(:title, title)]
    xpath = xpath[XPath.descendant(:img)[XPath.attr(:alt) == alt]] if alt
    xpath
  end

  node_filter(:href) do |node, href|
    # If not a Regexp it's been handled in the main XPath
    href.is_a?(Regexp) ? node[:href].match(href) : true
  end

  expression_filter(:download, valid_values: [true, false, String]) do |expr, download|
    mod = case download
    when true then XPath.attr(:download)
    when false then !XPath.attr(:download)
    when String then XPath.attr(:download) == download
    end
    expr[mod]
  end

  describe_expression_filters do |**options|
    desc = +''
    desc << " with href #{options[:href].inspect}" if options[:href] && !options[:href].is_a?(Regexp)
    desc << ' with no href attribute' if options.fetch(:href, true).nil?
    desc
  end

  describe_node_filters do |href: nil, **|
    " with href matching #{href.inspect}" if href.is_a? Regexp
  end
end

Capybara.add_selector(:button) do
  xpath(:value, :title, :type) do |locator, **options|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type) == 'image']

    unless locator.nil?
      locator = locator.to_s
      locator_matchers = XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)
      locator_matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      locator_matchers |= XPath.attr(test_id) == locator if test_id

      input_btn_xpath = input_btn_xpath[locator_matchers]

      btn_xpath = btn_xpath[locator_matchers | XPath.string.n.is(locator) | XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      image_btn_xpath = image_btn_xpath[alt_matches]
    end

    res_xpath = input_btn_xpath.union(btn_xpath).union(image_btn_xpath)

    res_xpath = expression_filters.keys.inject(res_xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }

    res_xpath
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  describe_expression_filters
  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end

Capybara.add_selector(:link_or_button) do
  label 'link or button'
  xpath do |locator, **options|
    self.class.all.values_at(:link, :button).map { |selector| selector.xpath.call(locator, options) }.reduce(:union)
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| node.tag_name == 'a' || !(value ^ node.disabled?) }

  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end

Capybara.add_selector(:fillable_field) do
  label 'field'

  xpath do |locator, **options|
    xpath = XPath.descendant(:input, :textarea)[!XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
    locate_field(xpath, locator, options)
  end

  expression_filter(:type) do |expr, type|
    type = type.to_s
    if type == 'textarea'
      expr.self(type.to_sym)
    else
      expr[XPath.attr(:type) == type]
    end
  end

  filter_set(:_field, %i[disabled multiple name placeholder])

  node_filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end

  describe_expression_filters
  describe_node_filters do |**options|
    " with value #{options[:with].to_s.inspect}" if options.key?(:with)
  end
end

Capybara.add_selector(:radio_button) do
  label 'radio button'

  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'radio']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[checked unchecked disabled name])

  node_filter(:option) { |node, value| node.value == value.to_s }

  describe_expression_filters
  describe_node_filters do |option: nil, **|
    " with value #{option.inspect}" if option
  end
end

Capybara.add_selector(:checkbox) do
  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'checkbox']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[checked unchecked disabled name])

  node_filter(:option) { |node, value| node.value == value.to_s }

  describe_expression_filters
  describe_node_filters do |option: nil, **|
    " with value #{option.inspect}" if option
  end
end

Capybara.add_selector(:select) do
  label 'select box'

  xpath do |locator, **options|
    xpath = XPath.descendant(:select)
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled multiple name placeholder])

  node_filter(:options) do |node, options|
    actual = if node.visible?
      node.all(:xpath, './/option', wait: false).map(&:text)
    else
      node.all(:xpath, './/option', visible: false, wait: false).map { |option| option.text(:all) }
    end
    options.sort == actual.sort
  end

  expression_filter(:with_options) do |expr, options|
    options.inject(expr) do |xpath, option|
      xpath[Capybara::Selector.all[:option].call(option)]
    end
  end

  node_filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
    Array(selected).sort == actual.sort
  end

  node_filter(:with_selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
    (Array(selected) - actual).empty?
  end

  describe_expression_filters do |with_options: nil, **opts|
    desc = +''
    desc << " with at least options #{with_options.inspect}" if with_options
    desc << describe_all_expression_filters(opts)
    desc
  end

  describe_node_filters do |options: nil, selected: nil, with_selected: nil, **|
    desc = +''
    desc << " with options #{options.inspect}" if options
    desc << " with #{selected.inspect} selected" if selected
    desc << " with at least #{with_selected.inspect} selected" if with_selected
    desc
  end
end

Capybara.add_selector(:datalist_input) do
  label 'input box with datalist completion'

  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:list)]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled name placeholder])

  node_filter(:options) do |node, options|
    actual = node.find("//datalist[@id=#{node[:list]}]", visible: :all).all(:datalist_option, wait: false).map(&:value)
    options.sort == actual.sort
  end

  expression_filter(:with_options) do |expr, options|
    options.inject(expr) do |xpath, option|
      xpath[XPath.attr(:list) == XPath.anywhere(:datalist)[Capybara::Selector.all[:datalist_option].call(option)].attr(:id)]
    end
  end

  describe_expression_filters do |with_options: nil, **opts|
    desc = +''
    desc << " with at least options #{with_options.inspect}" if with_options
    desc << describe_all_expression_filters(opts)
    desc
  end

  describe_node_filters do |options: nil, **|
    " with options #{options.inspect}" if options
  end
end

Capybara.add_selector(:option) do
  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
  node_filter(:selected, :boolean) { |node, value| !(value ^ node.selected?) }

  describe_node_filters do |**options|
    desc = +''
    desc << " that is#{' not' unless options[:disabled]} disabled" if options.key?(:disabled)
    desc << " that is#{' not' unless options[:selected]} selected" if options.key?(:selected)
    desc
  end
end

Capybara.add_selector(:datalist_option) do
  label 'datalist option'
  visible(:all)

  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s) | (XPath.attr(:value) == locator.to_s)] unless locator.nil?
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }

  describe_node_filters do |**options|
    " that is#{' not' unless options[:disabled]} disabled" if options.key?(:disabled)
  end
end

Capybara.add_selector(:file_field) do
  label 'file field'
  xpath do |locator, options|
    xpath = XPath.descendant(:input)[XPath.attr(:type) == 'file']
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled multiple name])

  describe_expression_filters
end

Capybara.add_selector(:label) do
  label 'label'
  xpath(:for) do |locator, options|
    xpath = XPath.descendant(:label)
    unless locator.nil?
      locator_matchers = XPath.string.n.is(locator.to_s) | (XPath.attr(:id) == locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    if options.key?(:for) && !options[:for].is_a?(Capybara::Node::Element)
      with_attr = XPath.attr(:for) == options[:for].to_s
      labelable_elements = %i[button input keygen meter output progress select textarea]
      wrapped = !XPath.attr(:for) &
                XPath.descendant(*labelable_elements)[XPath.attr(:id) == options[:for].to_s]
      xpath = xpath[with_attr | wrapped]
    end
    xpath
  end

  node_filter(:for) do |node, field_or_value|
    if field_or_value.is_a? Capybara::Node::Element
      if node[:for]
        field_or_value[:id] == node[:for]
      else
        field_or_value.find_xpath('./ancestor::label[1]').include? node.base
      end
    else
      true # Non element values were handled through the expression filter
    end
  end

  describe_expression_filters do |**options|
    " for element with id of \"#{options[:for]}\"" if options.key?(:for) && !options[:for].is_a?(Capybara::Node::Element)
  end
  describe_node_filters do |**options|
    " for element #{options[:for]}" if options[:for]&.is_a?(Capybara::Node::Element)
  end
end

Capybara.add_selector(:table) do
  xpath(:caption) do |locator, caption: nil, **|
    xpath = XPath.descendant(:table)
    unless locator.nil?
      locator_matchers = (XPath.attr(:id) == locator.to_s) | XPath.descendant(:caption).is(locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    xpath = xpath[XPath.descendant(:caption) == caption] if caption
    xpath
  end

  describe_expression_filters do |caption: nil, **|
    " with caption \"#{caption}\"" if caption
  end
end

Capybara.add_selector(:frame) do
  xpath(:name) do |locator, **options|
    xpath = XPath.descendant(:iframe).union(XPath.descendant(:frame))
    unless locator.nil?
      locator_matchers = (XPath.attr(:id) == locator.to_s) | (XPath.attr(:name) == locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    xpath = expression_filters.keys.inject(xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }
    xpath
  end

  describe_expression_filters do |name: nil, **|
    " with name #{name}" if name
  end
end

Capybara.add_selector(:element) do
  xpath do |locator, **|
    XPath.descendant((locator || '@').to_sym)
  end

  expression_filter(:attributes, matcher: /.+/) do |xpath, name, val|
    case val
    when Regexp
      xpath
    when XPath::Expression
      xpath[XPath.attr(name)[val]]
    else
      xpath[XPath.attr(name.to_sym) == val]
    end
  end

  node_filter(:attributes, matcher: /.+/) do |node, name, val|
    val.is_a?(Regexp) ? node[name] =~ val : true
  end

  describe_expression_filters
end
# rubocop:enable Metrics/BlockLength
