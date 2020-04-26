# frozen_string_literal: true

Capybara.add_selector(:fillable_field, locator_type: [String, Symbol]) do
  label 'field'
  xpath do |locator, allow_self: nil, **options|
    xpath = XPath.axis(allow_self ? :"descendant-or-self" : :descendant, :input, :textarea)[
      !XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')
    ]
    locate_field(xpath, locator, **options)
  end

  css do |_locator, **_options|
    invalid_types = %w[submit image radio checkbox hidden file]
    invalid_attributes = invalid_types.map { |type| ":not([type=#{type}])" }.join
    "input#{invalid_attributes}, textarea"
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
      if type == 'textarea'
        ::Capybara::Selector::CSS.split(expr).select do |css_fragment|
          css_fragment.start_with? type
        end.join(',')
      else
        ::Capybara::Selector::CSSBuilder.new(expr).add_attribute_conditions(type: type)
      end
    when :xpath
      if type == 'textarea'
        expr.self(type.to_sym)
      else
        expr[XPath.attr(:type) == type]
      end
    else
      raise ArgumentError, "Unknown format type: #{default_format}"
    end
  end

  filter_set(:_field, %i[disabled multiple name placeholder valid])

  node_filter(:with) do |node, with|
    val = node.value
    (with.is_a?(Regexp) ? with.match?(val) : val == with.to_s).tap do |res|
      add_error("Expected value to be #{with.inspect} but was #{val.inspect}") unless res
    end
  end

  describe_node_filters do |**options|
    " with value #{options[:with].to_s.inspect}" if options.key?(:with)
  end
end
