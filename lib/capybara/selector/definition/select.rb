# frozen_string_literal: true

Capybara.add_selector(:select, locator_type: [String, Symbol]) do
  label 'select box'

  xpath do |locator, **options|
    xpath = XPath.descendant(:select)
    locate_field(xpath, locator, **options)
  end

  filter_set(:_field, %i[disabled multiple name placeholder])

  node_filter(:options) do |node, options|
    actual = if node.visible?
      node.all(:xpath, './/option', wait: false).map(&:text)
    else
      node.all(:xpath, './/option', visible: false, wait: false).map { |option| option.text(:all) }
    end
    (options.sort == actual.sort).tap do |res|
      add_error("Expected options #{options.inspect} found #{actual.inspect}") unless res
    end
  end

  expression_filter(:with_options) do |expr, options|
    options.inject(expr) do |xpath, option|
      xpath[expression_for(:option, option)]
    end
  end

  node_filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false)
                 .select(&:selected?)
                 .map { |option| option.text(:all) }
    (Array(selected).sort == actual.sort).tap do |res|
      add_error("Expected #{selected.inspect} to be selected found #{actual.inspect}") unless res
    end
  end

  node_filter(:with_selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false)
                 .select(&:selected?)
                 .map { |option| option.text(:all) }
    (Array(selected) - actual).empty?.tap do |res|
      add_error("Expected at least #{selected.inspect} to be selected found #{actual.inspect}") unless res
    end
  end

  describe_expression_filters do |with_options: nil, **|
    desc = +''
    desc << " with at least options #{with_options.inspect}" if with_options
    desc
  end

  describe_node_filters do |options: nil, selected: nil, with_selected: nil, disabled: nil, **|
    desc = +''
    desc << " with options #{options.inspect}" if options
    desc << " with #{selected.inspect} selected" if selected
    desc << " with at least #{with_selected.inspect} selected" if with_selected
    desc << ' which is disabled' if disabled
    desc
  end
end
