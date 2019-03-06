# frozen_string_literal: true

Capybara.add_selector(:field, locator_type: [String, Symbol], supports_exact: true) do
  visible { |options| :hidden if options[:type].to_s == 'hidden' }

  xpath do |locator, **options|
    invalid_types = %w[submit image]
    invalid_types << 'hidden' unless options[:type].to_s == 'hidden'
    xpath = XPath.descendant(:input, :textarea, :select)[!XPath.attr(:type).one_of(*invalid_types)]
    locate_field(xpath, locator, **options)
  end

  css do |_locator, **options|
    invalid_types = %w[submit image]
    invalid_types << 'hidden' unless options[:type].to_s == 'hidden'
    invalid_attributes = invalid_types.map { |type| ":not([type=#{type}])" }.join
    "input#{invalid_attributes}, textarea, select"
  end

  locator_filter(skip_if: nil, format: :css) do |node, locator, exact:, **_|
    optional_checks = +''
    optional_checks << "(field.getAttribute('aria-label') == locator)||" if enable_aria_label
    optional_checks << "(field.getAttribute('#{test_id}') == locator)||" if test_id

    match_js = <<~JS
      (function(field, locator){
        return (
          (field.id == locator) ||
          (field.name == locator) ||
          (field.placeholder == locator)||
          #{optional_checks}
          Array.from(field.labels || []).some(function(label){
            return label.innerText#{exact ? '== locator' : '.includes(locator)'};
          })
        );
      })(this, arguments[0])
    JS
    node.evaluate_script(match_js, locator)
  end

  expression_filter(:type) do |expr, type|
    type = type.to_s
    case default_format
    when :css
      if %w[textarea select].include?(type)
        ::Capybara::Selector::CSS.split(expr).select do |css_fragment|
          css_fragment.start_with? type
        end.join(',')
      else
        ::Capybara::Selector::CSSBuilder.new(expr).add_attribute_conditions(type: type)
      end
    when :xpath
      if %w[textarea select].include?(type)
        expr.self(type.to_sym)
      else
        expr[XPath.attr(:type) == type]
      end
    else
      raise ArgumentError, "Unknown format type: #{default_format}"
    end
  end

  filter_set(:_field) # checked/unchecked/disabled/multiple/name/placeholder

  expression_filter(:name) do |expr, val|
    if default_format == :css
      ::Capybara::Selector::CSSBuilder.new(expr).add_attribute_conditions(name: val)
    else
      expr[XPath.attr(:name) == val]
    end
  end
  expression_filter(:placeholder) do |expr, val|
    if default_format == :css
      ::Capybara::Selector::CSSBuilder.new(expr).add_attribute_conditions(placeholder: val)
    else
      expr[XPath.attr(:placeholder) == val]
    end
  end
  expression_filter(:readonly, :boolean, format: :css) do |expr, val|
    ::Capybara::Selector::CSS.split(expr).map do |css_fragment|
      if val
        "#{css_fragment}:read-only"
      else
        "#{css_fragment}:read-write"
      end
    end.join(',')
  end

  node_filter(:readonly, :boolean, format: :xpath) do |node, value|
    !(value ^ node.readonly?)
  end

  node_filter(:with) do |node, with|
    val = node.value
    (with.is_a?(Regexp) ? with.match?(val) : val == with.to_s).tap do |res|
      add_error("Expected value to be #{with.inspect} but was #{val.inspect}") unless res
    end
  end

  describe_expression_filters do |type: nil, **|
    " of type #{type.inspect}" if type
  end

  describe_node_filters do |**options|
    " with value #{options[:with].to_s.inspect}" if options.key?(:with)
  end
end
