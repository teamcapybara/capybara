# frozen_string_literal: true

Capybara.add_selector(:label, locator_type: [String, Symbol]) do
  label 'label'
  xpath(:for) do |locator, options|
    xpath = XPath.descendant(:label)
    unless locator.nil?
      locator_matchers = XPath.string.n.is(locator.to_s) | (XPath.attr(:id) == locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    if options.key?(:for)
      if (for_option = options[:for].is_a?(Capybara::Node::Element) ? options[:for][:id] : options[:for])
        with_attr = XPath.attr(:for) == for_option.to_s
        labelable_elements = %i[button input keygen meter output progress select textarea]
        wrapped = !XPath.attr(:for) &
                  XPath.descendant(*labelable_elements)[XPath.attr(:id) == for_option.to_s]
        xpath = xpath[with_attr | wrapped]
      end
    end
    xpath
  end

  node_filter(:for) do |node, field_or_value|
    # Non element values were handled through the expression filter
    next true unless field_or_value.is_a? Capybara::Node::Element

    if (for_val = node[:for])
      field_or_value[:id] == for_val
    else
      field_or_value.find_xpath('./ancestor::label[1]').include? node.base
    end
  end

  describe_expression_filters do |**options|
    next unless options.key?(:for) && !options[:for].is_a?(Capybara::Node::Element)

    " for element with id of \"#{options[:for]}\""
  end
  describe_node_filters do |**options|
    " for element #{options[:for]}" if options[:for]&.is_a?(Capybara::Node::Element)
  end
end
