# frozen_string_literal: true

Capybara.add_selector(:button, locator_type: [String, Symbol]) do
  xpath(:value, :title, :type, :name) do |locator, **options|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    btn_xpath += XPath.descendant[XPath.attr(:role).equals('button')] if enable_aria_role
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type) == 'image']

    unless locator.nil?
      locator = locator.to_s
      locator_matchers = XPath.attr(:id).equals(locator) |
                         XPath.attr(:name).equals(locator) |
                         XPath.attr(:value).is(locator) |
                         XPath.attr(:title).is(locator) |
                         (XPath.attr(:id) == XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for))
      locator_matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      locator_matchers |= XPath.attr(test_id) == locator if test_id

      input_btn_xpath = input_btn_xpath[locator_matchers] + locate_label(locator).descendant(input_btn_xpath)

      btn_xpath = btn_xpath[locator_matchers |
                            XPath.string.n.is(locator) |
                            XPath.descendant(:img)[XPath.attr(:alt).is(locator)]
                           ] + locate_label(locator).descendant(btn_xpath)

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      image_btn_xpath = image_btn_xpath[alt_matches] + locate_label(locator).descendant(image_btn_xpath)
    end

    %i[value title type].inject(input_btn_xpath.union(btn_xpath).union(image_btn_xpath)) do |memo, ef|
      memo.where(find_by_attr(ef, options[ef]))
    end
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }

  node_filter(:name) { |node, value| !value.is_a?(Regexp) || value.match?(node[:name]) }
  expression_filter(:name) do |xpath, val|
    builder(xpath).add_attribute_conditions(name: val)
  end

  describe_expression_filters do |disabled: nil, **options|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    desc << describe_all_expression_filters(**options)
  end

  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end
