class Capybara::Selenium::Node < Capybara::Driver::Node
  def visible_text
    # Selenium doesn't normalize Unicode whitespace.
    Capybara::Helpers.normalize_whitespace(native.text)
  end

  def all_text
    text = driver.browser.execute_script("return arguments[0].textContent", native)
    Capybara::Helpers.normalize_whitespace(text)
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

  def set(value, fill_options={})
    tag_name = self.tag_name
    type = self[:type]
    if (Array === value) && !self[:multiple]
      raise ArgumentError.new "Value cannot be an Array when 'multiple' attribute is not present. Not a #{value.class}"
    end
    if tag_name == 'input' and type == 'radio'
      click
    elsif tag_name == 'input' and type == 'checkbox'
      click if value ^ native.attribute('checked').to_s.eql?("true")
    elsif tag_name == 'input' and type == 'file'
      path_names = value.to_s.empty? ? [] : value
      native.send_keys(*path_names)
    elsif tag_name == 'textarea' or tag_name == 'input'
      if self[:readonly]
        warn "Attempt to set readonly element with value: #{value} \n *This will raise an exception in a future version of Capybara"
      elsif value.to_s.empty?
        native.clear
      else
        if fill_options[:clear] == :backspace
          # Clear field by sending the correct number of backspace keys.
          backspaces = [:backspace] * self.value.to_s.length
          native.send_keys(*(backspaces + [value.to_s]))
        else
          # Clear field by JavaScript assignment of the value property.
          # Script can change a readonly element which user input cannot, so
          # don't execute if readonly.
          driver.browser.execute_script "arguments[0].value = ''", native
          native.send_keys(value.to_s)
        end
      end
    elsif native.attribute('isContentEditable')
      #ensure we are focused on the element
      script = <<-JS
        var range = document.createRange();
        range.selectNodeContents(arguments[0]);
        window.getSelection().addRange(range);
      JS
      driver.browser.execute_script script, native
      native.send_keys(value.to_s)
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

  def right_click
    driver.browser.action.context_click(native).perform
  end

  def double_click
    driver.browser.action.double_click(native).perform
  end

  def send_keys(*args)
    native.send_keys(*args)
  end

  def hover
    driver.browser.action.move_to(native).perform
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

  def disabled?
    !native.enabled?
  end

  alias :checked? :selected?

  def find_xpath(locator)
    native.find_elements(:xpath, locator).map { |n| self.class.new(driver, n) }
  end

  def find_css(locator)
    native.find_elements(:css, locator).map { |n| self.class.new(driver, n) }
  end

  def ==(other)
    native == other.native
  end

  def path
    path = find_xpath('ancestor::*').reverse
    path.unshift self

    result = []
    while node = path.shift
      parent = path.first

      if parent
        siblings = parent.find_xpath(node.tag_name)
        if siblings.size == 1
          result.unshift node.tag_name
        else
          index = siblings.index(node)
          result.unshift "#{node.tag_name}[#{index+1}]"
        end
      else
        result.unshift node.tag_name
      end
    end

    '/' + result.join('/')
  end

private

  # a reference to the select node if this is an option node
  def select_node
    find_xpath('./ancestor::select').first
  end
end
