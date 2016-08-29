# frozen_string_literal: true
require 'capybara/selector/selector'

Capybara::Selector::FilterSet.add(:_field) do
  filter(:checked, :boolean) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, :boolean) { |node, value| (value ^ node.checked?) }
  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| not(value ^ node.disabled?) }
  filter(:multiple, :boolean) { |node, value| !(value ^ node.multiple?) }

  describe do |options|
    desc, states = String.new, []
    states << 'checked' if options[:checked] || (options[:unchecked] === false)
    states << 'not checked' if options[:unchecked] || (options[:checked] === false)
    states << 'disabled' if options[:disabled] == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc << " with the multiple attribute" if options[:multiple] == true
    desc << " without the multiple attribute" if options[:multiple] === false
    desc
  end
end

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
  xpath(:id, :name, :placeholder, :type) do |locator, options|
    xpath = XPath.descendant(:input, :textarea, :select)[~XPath.attr(:type).one_of('submit', 'image', 'hidden')]
    if options[:type]
      type=options[:type].to_s
      if ['textarea', 'select'].include?(type)
        xpath = XPath.descendant(type.to_sym)
      else
        xpath = xpath[XPath.attr(:type).equals(type)]
      end
    end
    locate_field(xpath, locator, options)
  end

  filter_set(:_field) # checked/unchecked/disabled/multiple

  filter(:readonly, :boolean) { |node, value| not(value ^ node.readonly?) }
  filter(:with) do |node, with|
    with.is_a?(Regexp) ? node.value =~ with : node.value == with.to_s
  end
  describe do |options|
    desc = String.new
    (expression_filters - [:type]).each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc << " of type #{options[:type].inspect}" if options[:type]
    desc << " with value #{options[:with].to_s.inspect}" if options.has_key?(:with)
    desc
  end
end

Capybara.add_selector(:fieldset) do
  xpath(:id, :legend) do |locator, options|
    xpath = XPath.descendant(:fieldset)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.child(:legend)[XPath.string.n.is(locator.to_s)]] unless locator.nil?
    xpath = xpath[XPath.attr(:id).equals(options[:id])] if options[:id]
    xpath = xpath[XPath.child(:legend)[XPath.string.n.is(options[:legend])]] if options[:legend]
    xpath
  end
end

Capybara.add_selector(:link) do
  xpath(:id, :title, :alt) do |locator, options={}|
    xpath = XPath.descendant(:a)[XPath.attr(:href)]
    unless locator.nil?
      locator = locator.to_s
      matchers = XPath.attr(:id).equals(locator) |
                 XPath.string.n.is(locator) |
                 XPath.attr(:title).is(locator) |
                 XPath.descendant(:img)[XPath.attr(:alt).is(locator)]
      matchers |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label
      xpath = xpath[matchers]
    end
    xpath = xpath[XPath.attr(:id).equals(options[:id])] if options[:id]
    xpath = xpath[XPath.attr(:title).equals(options[:title])] if options[:title]
    xpath = xpath[XPath.descendant(:img)[XPath.attr(:alt).equals(options[:alt])]] if options[:alt]
    xpath
  end

  filter(:href) do |node, href|
    if href.is_a? Regexp
      node[:href].match href
    else
      node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)], minimum: 0)
    end
  end

  describe { |options| " with href #{options[:href].inspect}" if options[:href] }
end

Capybara.add_selector(:button) do
  xpath(:id, :value, :title) do |locator, options={}|
    input_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).one_of('submit', 'reset', 'image', 'button')]
    btn_xpath = XPath.descendant(:button)
    image_btn_xpath = XPath.descendant(:input)[XPath.attr(:type).equals('image')]

    unless locator.nil?
      locator = locator.to_s
      locator_matches = XPath.attr(:id).equals(locator) | XPath.attr(:value).is(locator) | XPath.attr(:title).is(locator)
      locator_matches |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label

      input_btn_xpath = input_btn_xpath[locator_matches]

      btn_xpath = btn_xpath[locator_matches | XPath.string.n.is(locator)]

      alt_matches = XPath.attr(:alt).is(locator)
      alt_matches |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label
      image_btn_xpath = image_btn_xpath[alt_matches]
    end

    res_xpath = input_btn_xpath + btn_xpath + image_btn_xpath

    (expression_filters & options.keys).inject(res_xpath) { |xpath, ef| xpath[XPath.attr(ef).equals(options[ef])] }

    res_xpath
  end

  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| not(value ^ node.disabled?) }

  describe do |options|
    desc = String.new
    desc << " that is disabled" if options[:disabled] == true
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:link_or_button) do
  label "link or button"
  xpath do |locator, options|
    self.class.all.values_at(:link, :button).map {|selector| selector.xpath.call(locator, options)}.reduce(:+)
  end

  filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| node.tag_name == "a" or not(value ^ node.disabled?) }

  describe { |options| " that is disabled" if options[:disabled] }
end

Capybara.add_selector(:fillable_field) do
  label "field"
  xpath(:id, :name, :placeholder) do |locator, options|
    xpath = XPath.descendant(:input, :textarea)[~XPath.attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, [:disabled, :multiple])

  describe do |options|
    desc = String.new
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:radio_button) do
  label "radio button"
  xpath(:id, :name) do |locator, options|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('radio')]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, [:checked, :unchecked, :disabled])

  filter(:option)  { |node, value|  node.value == value.to_s }

  describe do |options|
    desc = String.new
    desc << " with value #{options[:option].inspect}" if options[:option]
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:checkbox) do
  xpath(:id, :name) do |locator, options|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('checkbox')]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, [:checked, :unchecked, :disabled])

  filter(:option)  { |node, value|  node.value == value.to_s }

  describe do |options|
    desc = String.new
    desc << " with value #{options[:option].inspect}" if options[:option]
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:select) do
  label "select box"
  xpath(:id, :name, :placeholder) do |locator, options|
    xpath = XPath.descendant(:select)
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, [:disabled, :multiple])

  filter(:options) do |node, options|
    if node.visible?
      actual = node.all(:xpath, './/option').map { |option| option.text }
    else
      actual = node.all(:xpath, './/option', visible: false).map { |option| option.text(:all) }
    end
    options.sort == actual.sort
  end
  filter(:with_options) do |node, options|
    finder_settings = { minimum: 0 }
    if !node.visible?
      finder_settings[:visible] = false
    end
    options.all? { |option| node.first(:option, option, finder_settings) }
  end
  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option', visible: false).select { |option| option.selected? }.map { |option| option.text(:all) }
    [selected].flatten.sort == actual.sort
  end

  describe do |options|
    desc = String.new
    desc << " with options #{options[:options].inspect}" if options[:options]
    desc << " with at least options #{options[:with_options].inspect}" if options[:with_options]
    desc << " with #{options[:selected].inspect} selected" if options[:selected]
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:option) do
  xpath do |locator|
    xpath = XPath.descendant(:option)
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:disabled, :boolean) { |node, value| not(value ^ node.disabled?) }
  filter(:selected, :boolean) { |node, value| not(value ^ node.selected?) }

  describe do |options|
    desc = String.new
    desc << " that is#{' not' unless options[:disabled]} disabled" if options.has_key?(:disabled)
    desc << " that is#{' not' unless options[:selected]} selected" if options.has_key?(:selected)
    desc
  end
end

Capybara.add_selector(:file_field) do
  label "file field"
  xpath(:id, :name) do |locator, options|
    xpath = XPath.descendant(:input)[XPath.attr(:type).equals('file')]
    locate_field(xpath, locator, options)
  end

  filter_set(:_field, [:disabled, :multiple])

  describe do |options|
    desc = String.new
    expression_filters.each { |ef| desc << " with #{ef.to_s} #{options[ef]}" if options.has_key?(ef) }
    desc
  end
end

Capybara.add_selector(:label) do
  label "label"
  xpath do |locator|
    xpath = XPath.descendant(:label)
    xpath = xpath[XPath.string.n.is(locator.to_s) | XPath.attr(:id).equals(locator.to_s)] unless locator.nil?
    xpath
  end

  filter(:for) do |node, field_or_value|
    if field_or_value.is_a? Capybara::Node::Element
      if field_or_value[:id] && (field_or_value[:id] == node[:for])
        true
      else
        field_or_value.find_xpath('./ancestor::label[1]').include? node.base
      end
    else
      node[:for] == field_or_value.to_s
    end
  end

  describe do |options|
    desc = String.new
    desc << " for #{options[:for]}" if options[:for]
    desc
  end
end

Capybara.add_selector(:table) do
  xpath(:id, :caption) do |locator, options|
    xpath = XPath.descendant(:table)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.descendant(:caption).is(locator.to_s)] unless locator.nil?
    xpath = xpath[XPath.attr(:id).equals(options[:id])] if options[:id]
    xpath = xpath[XPath.descendant(:caption).equals(options[:caption])] if options[:caption]
    xpath
  end

  describe do |options|
    desc = String.new
    desc << " with id #{options[:id]}" if options[:id]
    desc << " with caption #{options[:caption]}" if options[:caption]
    desc
  end
end

Capybara.add_selector(:frame) do
  xpath(:id, :name) do |locator, options|
    xpath = XPath.descendant(:iframe) + XPath.descendant(:frame)
    xpath = xpath[XPath.attr(:id).equals(locator.to_s) | XPath.attr(:name).equals(locator)] unless locator.nil?
    [:id, :name].each { |ef| xpath = xpath[XPath.attr(ef).equals(options[ef])] if options[ef] }
    xpath
  end

  describe do |options|
    desc = String.new
    desc << " with id #{options[:id]}" if options[:id]
    desc << " with name #{options[:name]}" if options[:name]
    desc
  end
end
