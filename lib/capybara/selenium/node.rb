# frozen_string_literal: true
class Capybara::Selenium::Node < Capybara::Driver::Node
  def visible_text
    # Selenium doesn't normalize Unicode whitespace.
    Capybara::Helpers.normalize_whitespace(native.text)
  end

  def all_text
    text = driver.execute_script("return arguments[0].textContent", self)
    Capybara::Helpers.normalize_whitespace(text)
  end

  def [](name)
    native.attribute(name.to_s)
  rescue Selenium::WebDriver::Error::WebDriverError
    nil
  end

  def value
    if tag_name == "select" and multiple?
      native.find_elements(:css, "option:checked").map { |n| n[:value] || n.text }
    else
      native[:value]
    end
  end

  ##
  #
  # Set the value of the form element to the given value.
  #
  # @param [String] value    The new value
  # @param [Hash{}] options  Driver specific options for how to set the value
  # @option options [Symbol,Array] :clear (nil) The method used to clear the previous value <br/>
  #   nil => clear via javascript <br/>
  #   :none =>  append the new value to the existing value <br/>
  #   :backspace => send backspace keystrokes to clear the field <br/>
  #   Array => an array of keys to send before the value being set, e.g. [[:command, 'a'], :backspace]
  def set(value, options={})
    tag_name = self.tag_name
    type = self[:type]

    if (Array === value) && !multiple?
      raise ArgumentError.new "Value cannot be an Array when 'multiple' attribute is not present. Not a #{value.class}"
    end

    case tag_name
    when 'input'
      case type
      when 'radio'
        click
      when 'checkbox'
        click if value ^ native.attribute('checked').to_s.eql?("true")
      when 'file'
        path_names = value.to_s.empty? ? [] : value
        if driver.chrome?
          native.send_keys(Array(path_names).join("\n"))
        else
          native.send_keys(*path_names)
        end
      else
        set_text(value, options)
      end
    when 'textarea'
      set_text(value, options)
    else
      if content_editable?
        #ensure we are focused on the element
        click

        script = <<-JS
          var range = document.createRange();
          var sel = window.getSelection();
          arguments[0].focus();
          range.selectNodeContents(arguments[0]);
          sel.removeAllRanges();
          sel.addRange(range);
        JS
        driver.execute_script script, self

        if (driver.chrome?) || (driver.firefox? && !driver.marionette?)
          # chromedriver raises a can't focus element for child elements if we use native.send_keys
          # we've already focused it so just use action api
          driver.browser.action.send_keys(value.to_s).perform
        else
          # action api is really slow here just use native.send_keys
          native.send_keys(value.to_s)
        end
      end
    end
  end

  def select_option
    native.click unless selected? || disabled?
  end

  def unselect_option
    raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box." if !select_node.multiple?
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
  alias :checked? :selected?

  def disabled?
    # workaround for selenium-webdriver/geckodriver reporting elements as enabled when they are nested in disabling elements
    if driver.marionette?
      if %w(option optgroup).include? tag_name
        !native.enabled? || find_xpath("parent::*[self::optgroup or self::select]")[0].disabled?
      else
        !native.enabled? || !find_xpath("parent::fieldset[@disabled] | ancestor::*[not(self::legend) or preceding-sibling::legend][parent::fieldset[@disabled]]").empty?
      end
    else
      !native.enabled?
    end
  end

  def readonly?
    readonly = self[:readonly]
    readonly and readonly != "false"
  end

  def multiple?
    multiple = self[:multiple]
    multiple and multiple != "false"
  end

  def content_editable?
    native.attribute('isContentEditable')
  end

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
    find_xpath('./ancestor::select[1]').first
  end

  def set_text(value, options)
    if readonly?
      warn "Attempt to set readonly element with value: #{value} \n *This will raise an exception in a future version of Capybara"
    elsif value.to_s.empty? && options[:clear].nil?
      native.clear
    else
      if options[:clear] == :backspace
        # Clear field by sending the correct number of backspace keys.
        backspaces = [:backspace] * self.value.to_s.length
        native.send_keys(*(backspaces + [value.to_s]))
      elsif options[:clear] == :none
        native.send_keys(value.to_s)
      elsif options[:clear].is_a? Array
        native.send_keys(*options[:clear], value.to_s)
      else
        # Clear field by JavaScript assignment of the value property.
        # Script can change a readonly element which user input cannot, so
        # don't execute if readonly.
        driver.execute_script "arguments[0].value = ''", self
        native.send_keys(value.to_s)
      end
    end
  end
end
