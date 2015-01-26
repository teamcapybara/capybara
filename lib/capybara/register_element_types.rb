Capybara.register_element_type(:field) do
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  filter(:with) { |node, with| node.value == with.to_s }
  filter(:type) do |node, type|
    if ['textarea', 'select'].include?(type)
      node.tag_name == type
    else
      node[:type] == type
    end
  end
  describe do |options|
    desc, states = '', []
    desc << " of type #{options[:type].inspect}" if options[:type]
    desc << " with value #{options[:with].to_s.inspect}" if options.has_key?(:with)
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled]
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.register_element_type(:link_or_button) do
  label 'link or button'
  filter(:disabled, default: false, boolean: true) { |node, value| node.tag_name == 'a' or not(value ^ node.disabled?) }
  describe { |options| ' that is disabled' if options[:disabled] }
end

Capybara.register_element_type(:link) do
  filter(:href) do |node, href|
    node.first(:xpath, XPath.axis(:self)[XPath.attr(:href).equals(href.to_s)])
  end
  describe { |options| " with href #{options[:href].inspect}" if options[:href] }
end

Capybara.register_element_type(:button) do
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe { |options| ' that is disabled' if options[:disabled] }
end

Capybara.register_element_type(:fillable_field) do
  label 'field'
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe { |options| ' that is disabled' if options[:disabled] }
end

Capybara.register_element_type(:radio_button) do
  label 'radio button'
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc, states = '', []
    desc << " with value #{options[:option].inspect}" if options[:option]
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled]
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.register_element_type(:checkbox) do
  filter(:checked, boolean: true) { |node, value| not(value ^ node.checked?) }
  filter(:unchecked, boolean: true) { |node, value| (value ^ node.checked?) }
  filter(:option)  { |node, value|  node.value == value.to_s }
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc, states = '', []
    desc << " with value #{options[:option].inspect}" if options[:option]
    states << 'checked' if options[:checked] || (options.has_key?(:unchecked) && !options[:unchecked])
    states << 'not checked' if options[:unchecked] || (options.has_key?(:checked) && !options[:checked])
    states << 'disabled' if options[:disabled]
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

Capybara.register_element_type(:select) do
  label 'select box'
  filter(:options) do |node, options|
    actual = node.all(:xpath, './/option').map { |option| option.text }
    options.sort == actual.sort
  end
  filter(:with_options) { |node, options| options.all? { |option| node.first(:option, option) } }
  filter(:selected) do |node, selected|
    actual = node.all(:xpath, './/option').select { |option| option.selected? }.map { |option| option.text }
    [selected].flatten.sort == actual.sort
  end
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe do |options|
    desc = ''
    desc << " with options #{options[:options].inspect}" if options[:options]
    desc << " with at least options #{options[:with_options].inspect}" if options[:with_options]
    desc << " with #{options[:selected].inspect} selected" if options[:selected]
    desc << ' that is disabled' if options[:disabled]
    desc
  end
end

Capybara.register_element_type(:file_field) do
  label 'file field'
  filter(:disabled, default: false, boolean: true) { |node, value| not(value ^ node.disabled?) }
  describe { |options| ' that is disabled' if options[:disabled] }
end
