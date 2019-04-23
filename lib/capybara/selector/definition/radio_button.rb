# frozen_string_literal: true

Capybara.add_selector(:radio_button, locator_type: [String, Symbol]) do
  label 'radio button'
  xpath do |locator, allow_self: nil, **options|
    xpath = XPath.axis(allow_self ? :"descendant-or-self" : :descendant, :input)[
      XPath.attr(:type) == 'radio'
    ]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[checked unchecked disabled name])

  node_filter(:option) do |node, value|
    val = node.value
    (val == value.to_s).tap do |res|
      add_error("Expected option value to be #{value.inspect} but it was #{val.inspect}") unless res
    end
  end

  describe_node_filters do |option: nil, **|
    " with value #{option.inspect}" if option
  end
end
