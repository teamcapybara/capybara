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
    path_names = value.to_s.empty? ? [] : value
    Array(path_names).each do |path|
      unless driver.browser.respond_to?(:upload)
        if (fd = bridge.file_detector)
          local_file = fd.call([path])
          path = upload(local_file) if local_file
        end
      end
      native.send_keys(path)
    end
  end

  def send_keys(*args)
    # https://github.com/mozilla/geckodriver/issues/846
    return super(*args.map { |arg| arg == :space ? ' ' : arg }) if args.none? { |arg| arg.is_a? Array }

    native.click
    args.each_with_object(browser_action) do |keys, actions|
      _send_keys(keys, actions)
    end.perform
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

  def _send_keys(keys, actions, down_keys = nil)
    case keys
    when String
      keys = keys.upcase if down_keys&.include?(:shift) # https://bugzilla.mozilla.org/show_bug.cgi?id=1405370
      actions.send_keys(keys)
    when :space
      actions.send_keys(' ') # https://github.com/mozilla/geckodriver/issues/846
    when :control, :left_control, :right_control,
         :alt, :left_alt, :right_alt,
         :shift, :left_shift, :right_shift,
         :meta, :left_meta, :right_meta,
         :command
      if down_keys.nil?
        actions.send_keys(keys)
      else
        down_keys << keys
        actions.key_down(keys)
      end
    when Symbol
      actions.send_keys(keys)
    when Array
      local_down_keys = []
      keys.each do |sub_keys|
        _send_keys(sub_keys, actions, local_down_keys)
      end
      local_down_keys.each { |key| actions.key_up(key) }
    else
      raise ArgumentError, 'Unknown keys type'
    end
  end

  def bridge
    driver.browser.send(:bridge)
  end

  def upload(local_file)
    unless File.file?(local_file)
      raise ArgumentError, "You may only upload files: #{local_file.inspect}"
    end

    result = bridge.http.call(:post, "session/#{bridge.session_id}/file", file: Selenium::WebDriver::Zipper.zip_file(local_file))
    result['value']
  end

  def browser_version
    driver.browser.capabilities[:browser_version].to_f
  end
end
