# frozen_string_literal: true

require 'capybara/selector/xpath_extensions'
require 'capybara/selector/selector'

Capybara::Selector::FilterSet.add(:_field) do
  node_filter(:checked, :boolean) { |node, value| !(value ^ node.checked?) }
  node_filter(:unchecked, :boolean) { |node, value| (value ^ node.checked?) }
  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  expression_filter(:name) { |xpath, val| xpath[XPath.attr(:name) == val] }
  expression_filter(:placeholder) { |xpath, val| xpath[XPath.attr(:placeholder) == val] }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }
  expression_filter(:multiple) { |xpath, val| xpath[val ? XPath.attr(:multiple) : ~XPath.attr(:multiple)] }

  describe(:expression_filters) do |name: nil, placeholder: nil, disabled: nil, multiple: nil, **|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    desc << " with name #{name}" if name
    desc << " with placeholder #{placeholder}" if placeholder
    desc << ' with the multiple attribute' if multiple == true
    desc << ' without the multiple attribute' if multiple == false
    desc
  end

  describe(:node_filters) do |checked: nil, unchecked: nil, disabled: nil, **|
    desc, states = +'', []
    states << 'checked' if checked || (unchecked == false)
    states << 'not checked' if unchecked || (checked == false)
    states << 'disabled' if disabled == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

# rubocop:disable Metrics/BlockLength

Capybara.add_selector(:xpath, locator_type: [:to_xpath, String], raw_locator: true) do
  xpath { |xpath| xpath }
end

Capybara.add_selector(:css, locator_type: [String, Symbol], raw_locator: true) do
  css { |css| css }
end

Capybara.add_selector(:id, locator_type: [String, Symbol, Regexp]) do
  xpath { |id| builder(XPath.descendant).add_attribute_conditions(id: id) }
  locator_filter {  |node, id| id.is_a?(Regexp) ? id.match?(node[:id]) : true }
end

Capybara.add_selector(:field, locator_type: [String, Symbol]) do
  visible { |options| :hidden if options[:type].to_s == 'hidden' }
  xpath do |locator, **options|
    invalid_types = %w[submit image]
    invalid_types << 'hidden' unless options[:type].to_s == 'hidden'
    xpath = XPath.descendant(:input, :textarea, :select)[!XPath.attr(:type).one_of(*invalid_types)]
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

Capybara.add_selector(:fieldset, locator_type: [String, Symbol]) do
  xpath do |locator, legend: nil, **|
    locator_matchers = (XPath.attr(:id) == locator.to_s) | XPath.child(:legend)[XPath.string.n.is(locator.to_s)]
    locator_matchers |= XPath.attr(test_id) == locator.to_s if test_id
    xpath = XPath.descendant(:fieldset)[locator && locator_matchers]
    xpath = xpath[XPath.child(:legend)[XPath.string.n.is(legend)]] if legend
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }
end

Capybara.add_selector(:link, locator_type: [String, Symbol]) do
  xpath do |locator, href: true, alt: nil, title: nil, **|
    xpath = builder(XPath.descendant(:a)).add_attribute_conditions(href: href)

    unless locator.nil?
      locator = locator.to_s
      matchers = [XPath.attr(:id) == locator,
                  XPath.string.n.is(locator),
                  XPath.attr(:title).is(locator),
                  XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]
      matchers << XPath.attr(:'aria-label').is(locator) if enable_aria_label
      matchers << XPath.attr(test_id).equals(locator) if test_id
      xpath = xpath[matchers.reduce(:|)]
    end

    xpath = xpath[find_by_attr(:title, title)]
    xpath = xpath[XPath.descendant(:img)[XPath.attr(:alt) == alt]] if alt
    xpath
  end

  node_filter(:href) do |node, href|
    # If not a Regexp it's been handled in the main XPath
    (href.is_a?(Regexp) ? node[:href].match?(href) : true).tap do |res|
      add_error "Expected href to match #{href.inspect} but it was #{node[:href].inspect}" unless res
    end
  end

  expression_filter(:download, valid_values: [true, false, String]) do |expr, download|
    builder(expr).add_attribute_conditions(download: download)
  end

  describe_expression_filters do |download: nil, **options|
    desc = +''
    if (href = options[:href])
      desc << " with href #{'matching ' if href.is_a? Regexp}#{href.inspect}"
    elsif options.key?(:href) # is nil/false specified?
      desc << ' with no href attribute'
    end
    desc << " with download attribute#{" #{download}" if download.is_a? String}" if download
    desc << ' without download attribute' if download == false
    desc
  end
end

Capybara.add_selector(:button, locator_type: [String, Symbol]) do
  xpath(:value, :title, :type, :name) do |locator, **options|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type) == 'image']

    unless locator.nil?
      locator = locator.to_s
      locator_matchers = XPath.attr(:id).equals(locator) | XPath.attr(:name).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)
      locator_matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      locator_matchers |= XPath.attr(test_id) == locator if test_id

      input_btn_xpath = input_btn_xpath[locator_matchers]

      btn_xpath = btn_xpath[locator_matchers | XPath.string.n.is(locator) | XPath.descendant(:img)[XPath.attr(:alt).is(locator)]]

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      image_btn_xpath = image_btn_xpath[alt_matches]
    end

    %i[value title type name].inject(input_btn_xpath.union(btn_xpath).union(image_btn_xpath)) do |memo, ef|
      memo[find_by_attr(ef, options[ef])]
    end
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }

  describe_expression_filters do |disabled: nil, **options|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    desc << describe_all_expression_filters(options)
  end

  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end

Capybara.add_selector(:link_or_button, locator_type: [String, Symbol]) do
  label 'link or button'
  xpath do |locator, **options|
    self.class.all.values_at(:link, :button).map do |selector|
      instance_exec(locator, options, &selector.xpath)
    end.reduce(:union)
  end

  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  describe_node_filters do |disabled: nil, **|
    ' that is disabled' if disabled == true
  end
end

Capybara.add_selector(:fillable_field, locator_type: [String, Symbol]) do
  label 'field'
  xpath do |locator, allow_self: nil, **options|
    xpath = XPath.axis(allow_self ? :"descendant-or-self" : :descendant, :input, :textarea)[
      !XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')
    ]
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
    val = node.value
    (with.is_a?(Regexp) ? with.match?(val) : val == with.to_s).tap do |res|
      add_error("Expected value to be #{with.inspect} but was #{val.inspect}") unless res
    end
  end

  describe_node_filters do |**options|
    " with value #{options[:with].to_s.inspect}" if options.key?(:with)
  end
end

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

Capybara.add_selector(:checkbox, locator_type: [String, Symbol]) do
  xpath do |locator, allow_self: nil, **options|
    xpath = XPath.axis(allow_self ? :"descendant-or-self" : :descendant, :input)[
      XPath.attr(:type) == 'checkbox'
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

Capybara.add_selector(:select, locator_type: [String, Symbol]) do
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
    (options.sort == actual.sort).tap do |res|
      add_error("Expected options #{options.inspect} found #{actual.inspect}") unless res
    end
  end

  expression_filter(:with_options) do |expr, options|
    options.inject(expr) do |xpath, option|
      xpath[self.class.all[:option].call(option)]
    end
  end

  node_filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
    (Array(selected).sort == actual.sort).tap do |res|
      add_error("Expected #{selected.inspect} to be selected found #{actual.inspect}") unless res
    end
  end

  node_filter(:with_selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false, wait: false).select(&:selected?).map { |option| option.text(:all) }
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

Capybara.add_selector(:datalist_input, locator_type: [String, Symbol]) do
  label 'input box with datalist completion'

  xpath do |locator, **options|
    xpath = XPath.descendant(:input)[XPath.attr(:list)]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled name placeholder])

  node_filter(:options) do |node, options|
    actual = node.find("//datalist[@id=#{node[:list]}]", visible: :all).all(:datalist_option, wait: false).map(&:value)
    (options.sort == actual.sort).tap do |res|
      add_error("Expected #{options.inspect} options found #{actual.inspect}") unless res
    end
  end

  expression_filter(:with_options) do |expr, options|
    options.inject(expr) do |xpath, option|
      xpath[XPath.attr(:list) == XPath.anywhere(:datalist)[self.class.all[:datalist_option].call(option)].attr(:id)]
    end
  end

  describe_expression_filters do |with_options: nil, **|
    desc = +''
    desc << " with at least options #{with_options.inspect}" if with_options
    desc
  end

  describe_node_filters do |options: nil, **|
    " with options #{options.inspect}" if options
  end
end

Capybara.add_selector(:option, locator_type: [String, Symbol]) do
  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }

  node_filter(:selected, :boolean) { |node, value| !(value ^ node.selected?) }

  describe_expression_filters do |disabled: nil, **options|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    (expression_filters.keys & options.keys).inject(desc) { |memo, ef| memo << " with #{ef} #{options[ef]}" }
  end

  describe_node_filters do |**options|
    desc = +''
    desc << ' that is disabled' if options[:disabled]
    desc << " that is#{' not' unless options[:selected]} selected" if options.key?(:selected)
    desc
  end
end

Capybara.add_selector(:datalist_option, locator_type: [String, Symbol]) do
  label 'datalist option'
  visible(:all)

  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s) | (XPath.attr(:value) == locator.to_s)] unless locator.nil?
    xpath
  end

  node_filter(:disabled, :boolean) { |node, value| !(value ^ node.disabled?) }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }

  describe_expression_filters do |disabled: nil, **options|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    desc << describe_all_expression_filters(options)
  end

  describe_node_filters do |**options|
    ' that is disabled' if options[:disabled]
  end
end

Capybara.add_selector(:file_field, locator_type: [String, Symbol]) do
  label 'file field'
  xpath do |locator, allow_self: nil, **options|
    xpath = XPath.axis(allow_self ? :"descendant-or-self" : :descendant, :input)[
      XPath.attr(:type) == 'file'
    ]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, %i[disabled multiple name])
end

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
    " for element with id of \"#{options[:for]}\"" if options.key?(:for) && !options[:for].is_a?(Capybara::Node::Element)
  end
  describe_node_filters do |**options|
    " for element #{options[:for]}" if options[:for]&.is_a?(Capybara::Node::Element)
  end
end

Capybara.add_selector(:table, locator_type: [String, Symbol]) do
  xpath do |locator, caption: nil, **|
    xpath = XPath.descendant(:table)
    unless locator.nil?
      locator_matchers = (XPath.attr(:id) == locator.to_s) | XPath.descendant(:caption).is(locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    xpath = xpath[XPath.descendant(:caption) == caption] if caption
    xpath
  end

  expression_filter(:with_cols, valid_values: [Array]) do |xpath, cols|
    col_conditions = cols.map do |col|
      if col.is_a? Hash
        col.reduce(nil) do |xp, (header, cell_str)|
          header = XPath.descendant(:th)[XPath.string.n.is(header)]
          td = XPath.descendant(:tr)[header].descendant(:td)
          cell_condition = XPath.string.n.is(cell_str)
          cell_condition &= prev_col_position?(XPath.ancestor(:table)[1].join(xp)) if xp
          td[cell_condition]
        end
      else
        cells_xp = col.reduce(nil) do |prev_cell, cell_str|
          cell_condition = XPath.string.n.is(cell_str)

          if prev_cell
            prev_cell = XPath.ancestor(:tr)[1].preceding_sibling(:tr).join(prev_cell)
            cell_condition &= prev_col_position?(prev_cell)
          end

          XPath.descendant(:td)[cell_condition]
        end
        XPath.descendant(:tr).join(cells_xp)
      end
    end.reduce(:&)
    xpath[col_conditions]
  end

  expression_filter(:cols, valid_values: [Array]) do |xpath, cols|
    raise ArgumentError, ':cols must be an Array of Arrays' unless cols.all? { |col| col.is_a? Array }

    rows = cols.transpose
    col_conditions = rows.map { |row| match_row(row, match_size: true) }.reduce(:&)
    xpath[match_row_count(rows.size)][col_conditions]
  end

  expression_filter(:with_rows, valid_values: [Array]) do |xpath, rows|
    rows_conditions = rows.map { |row| match_row(row) }.reduce(:&)
    xpath[rows_conditions]
  end

  expression_filter(:rows, valid_values: [Array]) do |xpath, rows|
    rows_conditions = rows.map { |row| match_row(row, match_size: true) }.reduce(:&)
    xpath[match_row_count(rows.size)][rows_conditions]
  end

  describe_expression_filters do |caption: nil, **|
    " with caption \"#{caption}\"" if caption
  end

  def prev_col_position?(cell)
    XPath.position.equals(cell_position(cell))
  end

  def cell_position(cell)
    cell.preceding_sibling(:td).count.plus(1)
  end

  def match_row(row, match_size: false)
    xp = XPath.descendant(:tr)[
      if row.is_a? Hash
        row_match_cells_to_headers(row)
      else
        XPath.descendant(:td)[row_match_ordered_cells(row)]
      end
    ]
    xp = xp[XPath.descendant(:td).count.equals(row.size)] if match_size
    xp
  end

  def match_row_count(size)
    XPath.descendant(:tbody).descendant(:tr).count.equals(size) | (XPath.descendant(:tr).count.equals(size) & ~XPath.descendant(:tbody))
  end

  def row_match_cells_to_headers(row)
    row.map do |header, cell|
      header_xp = XPath.ancestor(:table)[1].descendant(:tr)[1].descendant(:th)[XPath.string.n.is(header)]
      XPath.descendant(:td)[
        XPath.string.n.is(cell) & XPath.position.equals(header_xp.preceding_sibling.count.plus(1))
      ]
    end.reduce(:&)
  end

  def row_match_ordered_cells(row)
    row_conditions = row.map do |cell|
      XPath.self(:td)[XPath.string.n.is(cell)]
    end
    row_conditions.reverse.reduce do |cond, cell|
      cell[XPath.following_sibling[cond]]
    end
  end
end

Capybara.add_selector(:table_row, locator_type: [Array, Hash]) do
  xpath do |locator|
    xpath = XPath.descendant(:tr)
    if locator.is_a? Hash
      locator.reduce(xpath) do |xp, (header, cell)|
        header_xp = XPath.ancestor(:table)[1].descendant(:tr)[1].descendant(:th)[XPath.string.n.is(header)]
        cell_xp = XPath.descendant(:td)[
          XPath.string.n.is(cell) & XPath.position.equals(header_xp.preceding_sibling.count.plus(1))
        ]
        xp[cell_xp]
      end
    else
      initial_td = XPath.descendant(:td)[XPath.string.n.is(locator.shift)]
      tds = locator.reverse.map { |cell| XPath.following_sibling(:td)[XPath.string.n.is(cell)] }.reduce { |xp, cell| xp[cell] }
      xpath[initial_td[tds]]
    end
  end
end

Capybara.add_selector(:frame, locator_type: [String, Symbol]) do
  xpath do |locator, name: nil, **|
    xpath = XPath.descendant(:iframe).union(XPath.descendant(:frame))
    unless locator.nil?
      locator_matchers = (XPath.attr(:id) == locator.to_s) | (XPath.attr(:name) == locator.to_s)
      locator_matchers |= XPath.attr(test_id) == locator if test_id
      xpath = xpath[locator_matchers]
    end
    xpath[find_by_attr(:name, name)]
  end

  describe_expression_filters do |name: nil, **|
    " with name #{name}" if name
  end
end

Capybara.add_selector(:element, locator_type: [String, Symbol]) do
  xpath do |locator, **|
    XPath.descendant.where(locator ? XPath.local_name == locator.to_s : nil)
  end

  expression_filter(:attributes, matcher: /.+/) do |xpath, name, val|
    builder(xpath).add_attribute_conditions(name => val)
  end

  node_filter(:attributes, matcher: /.+/) do |node, name, val|
    next true unless val.is_a?(Regexp)

    (val.match? node[name]).tap do |res|
      add_error("Expected #{name} to match #{val.inspect} but it was #{node[name]}") unless res
    end
  end

  describe_expression_filters do |**options|
    booleans, values = options.partition { |_k, v| [true, false].include? v }.map(&:to_h)
    desc = describe_all_expression_filters(values)
    desc + booleans.map do |k, v|
      v ? " with #{k} attribute" : "without #{k} attribute"
    end.join
  end
end
# rubocop:enable Metrics/BlockLength
