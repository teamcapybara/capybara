class Capybara::RackTest::Node < Capybara::Driver::Node
  def text
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
    if tag_name == 'input' and type == 'radio'
      other_radios_xpath = XPath.generate { |x| x.anywhere(:input)[x.attr(:name).equals(self[:name])] }.to_s
      driver.dom.xpath(other_radios_xpath).each { |node| node.remove_attribute("checked") }
      native['checked'] = 'checked'
    elsif tag_name == 'input' and type == 'checkbox'
      if value && !native['checked']
        native['checked'] = 'checked'
      elsif !value && native['checked']
        native.remove_attribute('checked')
      end
    elsif tag_name == 'input'
      if (type == 'text' || type == 'password') && self[:maxlength] &&
        !self[:maxlength].empty?
        # Browser behavior for maxlength="0" is inconsistent, so we stick with
        # Firefox, allowing no input
        value = value[0...self[:maxlength].to_i]
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
        native['value'] = value.to_s
      end
    elsif tag_name == "textarea"
      native.content = value.to_s
    end
  end

  def select_option
    if select_node['multiple'] != 'multiple'
      select_node.find(".//option[@selected]").each { |node| node.native.remove_attribute("selected") }
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
    if tag_name == 'a'
      method = self["data-method"] if driver.options[:respect_data_method]
      method ||= :get
      driver.follow(method, self[:href].to_s)
    elsif (tag_name == 'input' and %w(submit image).include?(type)) or
        ((tag_name == 'button') and type.nil? or type == "submit")
      Capybara::RackTest::Form.new(driver, form).submit(self)
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

  def path
    native.path
  end

  def find(locator)
    native.xpath(locator).map { |n| self.class.new(driver, n) }
  end

  def ==(other)
    native == other.native
  end

protected

  def unnormalized_text
    if !visible?
      ''
    elsif native.text?
      native.text
    elsif native.element?
      native.children.map do |child|
        Capybara::RackTest::Node.new(driver, child).unnormalized_text
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
    find('./ancestor::select').first
  end

  def type
    native[:type]
  end

  def form
    native.ancestors('form').first
  end
end
