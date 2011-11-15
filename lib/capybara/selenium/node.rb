class Capybara::Selenium::Node < Capybara::Driver::Node
  def text
    native.text
  end

  def [](name)
    native.attribute(name.to_s)
  rescue Selenium::WebDriver::Error::WebDriverError
    nil
  end

  def value
    if tag_name == "select" and self[:multiple] and not self[:multiple] == "false"
      native.find_elements(:xpath, ".//option").select { |n| n.selected? }.map { |n| n[:value] || n.text }
    else
      native[:value]
    end
  end

  def set(value)
    if tag_name == 'input' and type == 'radio'
      click
    elsif tag_name == 'input' and type == 'checkbox'
      click if value ^ native.attribute('checked').to_s.eql?("true")
    elsif tag_name == 'input' and type == 'file'
      resynchronize do
        native.send_keys(value.to_s)
      end
    elsif tag_name == 'textarea' or tag_name == 'input'
      resynchronize do
        native.clear
        native.send_keys(value.to_s)
      end
    end
  end

  def select_option
    resynchronize { native.click } unless selected?
  end

  def unselect_option
    if select_node['multiple'] != 'multiple' and select_node['multiple'] != 'true'
      raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
    end
    resynchronize { native.click } if selected?
  end

  def click
    resynchronize { native.click }
  end

  def drag_to(element)
    resynchronize { driver.browser.action.drag_and_drop(native, element.native).perform }
  end

  def tag_name
    native.tag_name.downcase
  end

  def visible?
    displayed = native.displayed?
    displayed and displayed != "false"
  end

  def selected?
    selected = native.selected?
    selected and selected != "false"
  end

  alias :checked? :selected?

  def find(locator)
    native.find_elements(:xpath, locator).map { |n| self.class.new(driver, n) }
  end

private

  def resynchronize
    driver.resynchronize { yield }
  end

  # a reference to the select node if this is an option node
  def select_node
    find('./ancestor::select').first
  end

  def type
    self[:type]
  end

end
