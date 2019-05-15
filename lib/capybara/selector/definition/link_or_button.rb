# frozen_string_literal: true

Capybara.add_selector(:link_or_button, locator_type: [String, Symbol]) do
  label 'link or button'
  xpath do |locator, **options|
    expression_for(:link, locator, **options.merge(href: false))
      .union(expression_for(:button, locator, **options))
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end
