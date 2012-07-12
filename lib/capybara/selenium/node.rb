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
      native.send_keys(value.to_s)
    elsif tag_name == 'textarea' or tag_name == 'input'
      # per dw_henry's fix for multiple onchange triggers in the Capybara user group:
      # https://groups.google.com/forum/?fromgroups#!topic/ruby-capybara/LZ6eu0kuRY0
      keys = [] 

      # node.clear triggers onchange
      keys << "\b" * native[:value].size if native[:value] 
      keys << value.to_s 
      native.send_keys(keys) 

      # execute onchange script after update is finished if it exists.. 
      native.bridge.executeScript("$('#{native[:id]}').onchange()") if native[:onchange] 
    end
  end

  def select_option
    native.click unless selected?
  end

  def unselect_option
    if select_node['multiple'] != 'multiple' and select_node['multiple'] != 'true'
      raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
    end
    native.click if selected?
  end

  def click
    native.click
  end

  def drag_to(element)
    driver.browser.action.drag_and_drop(native, element.native).perform
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

  # a reference to the select node if this is an option node
  def select_node
    find('./ancestor::select').first
  end

  def type
    self[:type]
  end

end
