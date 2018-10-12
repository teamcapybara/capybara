# frozen_string_literal: true

require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::MarionetteNode < Capybara::Selenium::Node
  include Html5Drag

  def click(keys = [], **options)
    super
  rescue ::Selenium::WebDriver::Error::ElementNotInteractableError
    if tag_name == 'tr'
      warn 'You are attempting to click a table row which has issues in geckodriver/marionette - see https://github.com/mozilla/geckodriver/issues/1228. ' \
           'Your test should probably be clicking on a table cell like a user would. Clicking the first cell in the row instead.'
      return find_css('th:first-child,td:first-child')[0].click(keys, options)
    end
    raise
  end

  def disabled?
    # Not sure exactly what version of FF fixed the below issue, but it is definitely fixed in 61+
    return super unless browser_version < 61.0

    return true if super

    # workaround for selenium-webdriver/geckodriver reporting elements as enabled when they are nested in disabling elements
    if %w[option optgroup].include? tag_name
      find_xpath('parent::*[self::optgroup or self::select]')[0].disabled?
    else
      !find_xpath('parent::fieldset[@disabled] | ancestor::*[not(self::legend) or preceding-sibling::legend][parent::fieldset[@disabled]]').empty?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    # By default files are appended so we have to clear here if its multiple and already set
    native.clear if multiple? && driver.evaluate_script('arguments[0].files', self).any?
    return super if browser_version >= 62.0

    # Workaround lack of support for multiple upload by uploading one at a time
    path_names = value.to_s.empty? ? [] : Array(value)
    if (fd = bridge.file_detector) && !driver.browser.respond_to?(:upload)
      path_names.map! { |path| upload(fd.call([path])) || path }
    end
    path_names.each { |path| native.send_keys(path) }
  end

  def send_keys(*args)
    # https://github.com/mozilla/geckodriver/issues/846
    return super(*args.map { |arg| arg == :space ? ' ' : arg }) if args.none? { |arg| arg.is_a? Array }

    native.click
    _send_keys(args).perform
  end

  def drag_to(element)
    return super unless (browser_version >= 62.0) && html5_draggable?

    html5_drag_to(element)
  end

private

  def click_with_options(click_options)
    # Firefox/marionette has an issue clicking with offset near viewport edge
    # scroll element to middle just in case
    scroll_to_center if click_options.coords?
    super
  end

  def _send_keys(keys, actions = browser_action, down_keys = ModifierKeysStack.new)
    case keys
    when :control, :left_control, :right_control,
         :alt, :left_alt, :right_alt,
         :shift, :left_shift, :right_shift,
         :meta, :left_meta, :right_meta,
         :command
      down_keys.press(keys)
      actions.key_down(keys)
    when String
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1405370
      keys = keys.upcase if (browser_version < 64.0) && down_keys&.include?(:shift)
      actions.send_keys(keys)
    when Symbol
      actions.send_keys(keys)
    when Array
      down_keys.push
      keys.each { |sub_keys| _send_keys(sub_keys, actions, down_keys) }
      down_keys.pop.reverse_each { |key| actions.key_up(key) }
    else
      raise ArgumentError, 'Unknown keys type'
    end
    actions
  end

  def bridge
    driver.browser.send(:bridge)
  end

  def upload(local_file)
    return nil unless local_file
    raise ArgumentError, "You may only upload files: #{local_file.inspect}" unless File.file?(local_file)

    result = bridge.http.call(:post, "session/#{bridge.session_id}/file", file: Selenium::WebDriver::Zipper.zip_file(local_file))
    result['value']
  end

  def browser_version
    driver.browser.capabilities[:browser_version].to_f
  end

  class ModifierKeysStack
    def initialize
      @stack = []
    end

    def include?(key)
      @stack.flatten.include?(key)
    end

    def press(key)
      @stack.last.push(key)
    end

    def push
      @stack.push []
    end

    def pop
      @stack.pop
    end
  end
  private_constant :ModifierKeysStack
end
