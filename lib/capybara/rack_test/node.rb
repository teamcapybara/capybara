# frozen_string_literal: true
class Capybara::RackTest::Node < Capybara::Driver::Node
  def all_text
    Capybara::Helpers.normalize_whitespace(native.text)
  end

  def visible_text
    Capybara::Helpers.normalize_whitespace(unnormalized_text)
  end

  def [](name)
    string_node[name]
  end

  def value
    string_node.value
  end

  def set(value)
    if (Array === value) && !self[:multiple]
      raise ArgumentError.new "Value cannot be an Array when 'multiple' attribute is not present. Not a #{value.class}"
    end

    if radio?
      set_radio(value)
    elsif checkbox?
      set_checkbox(value)
    elsif input_field?
      set_input(value)
    elsif textarea?
      if self[:readonly]
        warn "Attempt to set readonly element with value: #{value} \n * This will raise an exception in a future version of Capybara"
      else
        native.content = value.to_s
      end
    end
  end

  def select_option
    return if disabled?
    if select_node['multiple'] != 'multiple'
      select_node.find_xpath(".//option[@selected]").each { |node| node.native.remove_attribute("selected") }
    end
    native["selected"] = 'selected'
  end

  def unselect_option
    if select_node['multiple'] != 'multiple'
      raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
    end
    native.remove_attribute('selected')
  end

  def click
    if tag_name == 'a' && !self[:href].nil?
      method = self["data-method"] if driver.options[:respect_data_method]
      method ||= :get
      driver.follow(method, self[:href].to_s)
    elsif (tag_name == 'input' and %w(submit image).include?(type)) or
        ((tag_name == 'button') and type.nil? or type == "submit")
      associated_form = form
      Capybara::RackTest::Form.new(driver, associated_form).submit(self) if associated_form
    end
  end

  def tag_name
    native.node_name
  end

  def visible?
    string_node.visible?
  end

  def checked?
    string_node.checked?
  end

  def selected?
    string_node.selected?
  end

  def disabled?
    if %w(option optgroup).include? tag_name
      string_node.disabled? || find_xpath("parent::*")[0].disabled?
    else
      string_node.disabled?
    end
  end

  def path
    native.path
  end

  def find_xpath(locator)
    native.xpath(locator).map { |n| self.class.new(driver, n) }
  end

  def find_css(locator)
    native.css(locator, Capybara::RackTest::CSSHandlers.new).map { |n| self.class.new(driver, n) }
  end

  def ==(other)
    native == other.native
  end

protected

  def unnormalized_text(check_ancestor_visibility = true)
    if !string_node.visible?(check_ancestor_visibility)
      ''
    elsif native.text?
      native.text
    elsif native.element?
      native.children.map do |child|
        Capybara::RackTest::Node.new(driver, child).unnormalized_text(false)
      end.join
    else
      ''
    end
  end

private

  def string_node
    @string_node ||= Capybara::Node::Simple.new(native)
  end

  # a reference to the select node if this is an option node
  def select_node
    find_xpath('./ancestor::select').first
  end

  def type
    native[:type]
  end

  def form
    if native[:form]
      native.xpath("//form[@id='#{native[:form]}']").first
    else
      native.ancestors('form').first
    end
  end

  def set_radio(value)
    other_radios_xpath = XPath.generate { |x| x.anywhere(:input)[x.attr(:name).equals(self[:name])] }.to_s
    driver.dom.xpath(other_radios_xpath).each { |node| node.remove_attribute("checked") }
    native['checked'] = 'checked'
  end

  def set_checkbox(value)
    if value && !native['checked']
      native['checked'] = 'checked'
    elsif !value && native['checked']
      native.remove_attribute('checked')
    end
  end

  def set_input(value)
    if text_or_password? && attribute_is_not_blank?(:maxlength)
      # Browser behavior for maxlength="0" is inconsistent, so we stick with
      # Firefox, allowing no input
      value = value.to_s[0...self[:maxlength].to_i]
    end
    if Array === value #Assert multiple attribute is present
      value.each do |v|
        new_native = native.clone
        new_native.remove_attribute('value')
        native.add_next_sibling(new_native)
        new_native['value'] = v.to_s
      end
      native.remove
    else
      if self[:readonly]
        warn "Attempt to set readonly element with value: #{value} \n *This will raise an exception in a future version of Capybara"
      else
        native['value'] = value.to_s
      end
    end
  end

  def attribute_is_not_blank?(attribute)
    self[attribute] && !self[attribute].empty?
  end

  def checkbox?
    input_field? && type == 'checkbox'
  end

  def input_field?
    tag_name == 'input'
  end

  def radio?
    input_field? && type == 'radio'
  end

  def textarea?
    tag_name == "textarea"
  end

  def text_or_password?
    input_field? && (type == 'text' || type == 'password')
  end
end
