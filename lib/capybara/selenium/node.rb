# frozen_string_literal: true

class Capybara::Selenium::Node < Capybara::Driver::Node
  def visible_text
    native.text
  end

  def all_text
    text = driver.execute_script("return arguments[0].textContent", self)
    text.gsub(/[\u200b\u200e\u200f]/, '')
        .gsub(/[\ \n\f\t\v\u2028\u2029]+/, ' ')
        .gsub(/\A[[:space:]&&[^\u00a0]]+/, "")
        .gsub(/[[:space:]&&[^\u00a0]]+\z/, "")
        .tr("\u00a0", ' ')
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
  def set(value, **options)
    raise ArgumentError, "Value cannot be an Array when 'multiple' attribute is not present. Not a #{value.class}" if value.is_a?(Array) && !multiple?

    case tag_name
    when 'input'
      case self[:type]
      when 'radio'
        click
      when 'checkbox'
        click if value ^ checked?
      when 'file'
        set_file(value)
      when 'date'
        set_date(value)
      when 'time'
        set_time(value)
      when 'datetime-local'
        set_datetime_local(value)
      else
        set_text(value, options)
      end
    when 'textarea'
      set_text(value, options)
    else
      set_content_editable(value) if content_editable?
    end
  end

  def select_option
    native.click unless selected? || disabled?
  end

  def unselect_option
    raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box." unless select_node.multiple?
    native.click if selected?
  end

  def click(keys = [], options = {})
    if keys.empty? && !(options[:x] && options[:y])
      native.click
    else
      scroll_if_needed do
        action_with_modifiers(keys, options) do |a|
          if options[:x] && options[:y]
            a.click
          else
            a.click(native)
          end
        end
      end
    end
  rescue => e
    if e.is_a?(::Selenium::WebDriver::Error::ElementClickInterceptedError) ||
       e.message =~ /Other element would receive the click/
      begin
        driver.execute_script("arguments[0].scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'})", self)
      rescue # Swallow error if scrollIntoView with options isn't supported
      end
    end
    raise e
  end

  def right_click(keys = [], options = {})
    scroll_if_needed do
      action_with_modifiers(keys, options) do |a|
        if options[:x] && options[:y]
          a.context_click
        else
          a.context_click(native)
        end
      end
    end
  end

  def double_click(keys = [], options = {})
    scroll_if_needed do
      action_with_modifiers(keys, options) do |a|
        if options[:x] && options[:y]
          a.double_click
        else
          a.double_click(native)
        end
      end
    end
  end

  def send_keys(*args)
    native.send_keys(*args)
  end

  def hover
    scroll_if_needed { driver.browser.action.move_to(native).perform }
  end

  def drag_to(element)
    scroll_if_needed { driver.browser.action.drag_and_drop(native, element.native).perform }
  end

  def tag_name
    native.tag_name.downcase
  end

  def visible?; boolean_attr(native.displayed?); end
  def readonly?; boolean_attr(self[:readonly]); end
  def multiple?; boolean_attr(self[:multiple]); end
  def selected?; boolean_attr(native.selected?); end
  alias :checked? :selected?

  def disabled?
    return true unless native.enabled?

    # workaround for selenium-webdriver/geckodriver reporting elements as enabled when they are nested in disabling elements
    if driver.marionette?
      if %w[option optgroup].include? tag_name
        find_xpath("parent::*[self::optgroup or self::select]")[0].disabled?
      else
        !find_xpath("parent::fieldset[@disabled] | ancestor::*[not(self::legend) or preceding-sibling::legend][parent::fieldset[@disabled]]").empty?
      end
    else
      false
    end
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
    path = find_xpath(XPath.ancestor_or_self).reverse

    result = []
    while (node = path.shift)
      parent = path.first
      selector = node.tag_name
      if parent
        siblings = parent.find_xpath(selector)
        selector += "[#{siblings.index(node) + 1}]" unless siblings.size == 1
      end
      result.push selector
    end

    '/' + result.reverse.join('/')
  end

private

  def boolean_attr(val)
    val and val != "false"
  end

  # a reference to the select node if this is an option node
  def select_node
    find_xpath(XPath.ancestor(:select)[1]).first
  end

  def set_text(value, clear: nil, **_unused)
    if value.to_s.empty? && clear.nil?
      native.clear
    elsif clear == :backspace
      # Clear field by sending the correct number of backspace keys.
      backspaces = [:backspace] * self.value.to_s.length
      native.send_keys(*(backspaces + [value.to_s]))
    elsif clear == :none
      native.send_keys(value.to_s)
    elsif clear.is_a? Array
      native.send_keys(*clear, value.to_s)
    else
      # Clear field by JavaScript assignment of the value property.
      # Script can change a readonly element which user input cannot, so
      # don't execute if readonly.
      driver.execute_script "arguments[0].value = ''", self
      native.send_keys(value.to_s)
    end
  end

  def scroll_if_needed
    yield
  rescue ::Selenium::WebDriver::Error::MoveTargetOutOfBoundsError
    script = <<-'JS'
      try {
        arguments[0].scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'});
      } catch(e) {
        arguments[0].scrollIntoView(true);
      }
    JS
    driver.execute_script(script, self)
    yield
  end

  def set_date(value) # rubocop:disable Naming/AccessorMethodName
    return set_text(value) if value.is_a?(String) || !value.respond_to?(:to_date)
    # TODO: this would be better if locale can be detected and correct keystrokes sent
    update_value_js(value.to_date.strftime('%Y-%m-%d'))
  end

  def set_time(value) # rubocop:disable Naming/AccessorMethodName
    return set_text(value) if value.is_a?(String) || !value.respond_to?(:to_time)
    # TODO: this would be better if locale can be detected and correct keystrokes sent
    update_value_js(value.to_time.strftime('%H:%M'))
  end

  def set_datetime_local(value) # rubocop:disable Naming/AccessorMethodName
    return set_text(value) if value.is_a?(String) || !value.respond_to?(:to_time)
    # TODO: this would be better if locale can be detected and correct keystrokes sent
    update_value_js(value.to_time.strftime('%Y-%m-%dT%H:%M'))
  end

  def update_value_js(value)
    driver.execute_script(<<-JS, self, value)
      if (document.activeElement !== arguments[0]){
        arguments[0].focus();
      }
      if (arguments[0].value != arguments[1]) {
        arguments[0].value = arguments[1]
        arguments[0].dispatchEvent(new InputEvent('input'));
        arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
      }
      JS
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    path_names = value.to_s.empty? ? [] : value
    if driver.marionette?
      native.clear
      Array(path_names).each { |p| native.send_keys(p) }
    else
      native.send_keys(Array(path_names).join("\n"))
    end
  end

  def set_content_editable(value) # rubocop:disable Naming/AccessorMethodName
    # Ensure we are focused on the element
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

    # The action api has a speed problem but both chrome and firefox 58 raise errors
    # if we use the faster direct send_keys.  For now just send_keys to the element
    # we've already focused.
    # native.send_keys(value.to_s)
    driver.browser.action.send_keys(value.to_s).perform
  end

  def action_with_modifiers(keys, x: nil, y: nil)
    actions = driver.browser.action
    actions.move_to(native, x, y)
    modifiers_down(actions, keys)
    yield actions
    modifiers_up(actions, keys)
    actions.perform
  ensure
    a = driver.browser.action
    a.release_actions if a.respond_to?(:release_actions)
  end

  def modifiers_down(actions, keys)
    keys.each do |key|
      key = case key
      when :ctrl then :control
      when :command, :cmd then :meta
      else
        key
      end
      actions.key_down(key)
    end
  end

  def modifiers_up(actions, keys)
    keys.each do |key|
      key = case key
      when :ctrl then :control
      when :command, :cmd then :meta
      else
        key
      end
      actions.key_up(key)
    end
  end
end
