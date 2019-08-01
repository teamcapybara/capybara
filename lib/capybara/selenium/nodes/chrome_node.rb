# frozen_string_literal: true

require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::ChromeNode < Capybara::Selenium::Node
  include Html5Drag

  def set_text(value, clear: nil, **_unused)
    super.tap do
      # React doesn't see the chromedriver element clear
      send_keys(:space, :backspace) if value.to_s.empty? && clear.nil?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    # In Chrome 75+ files are appended (due to WebDriver spec - why?) so we have to clear here if its multiple and already set
    if browser_version >= 75.0
      driver.execute_script(<<~JS, self)
        if (arguments[0].multiple && (arguments[0].files.length > 0)){
          arguments[0].value = null;
        }
      JS
    end
    super
  rescue *file_errors => e
    raise ArgumentError, "Selenium < 3.14 with remote Chrome doesn't support multiple file upload" if e.message.match?(/File not found : .+\n.+/m)

    raise
  end

  def drop(*args)
    html5_drop(*args)
  end

  def click(*)
    super
  rescue ::Selenium::WebDriver::Error::ElementClickInterceptedError
    raise
  rescue ::Selenium::WebDriver::Error::WebDriverError => e
    # chromedriver 74 (at least on mac) raises the wrong error for this
    raise ::Selenium::WebDriver::Error::ElementClickInterceptedError, e.message if e.message.match?(/element click intercepted/)

    raise
  end

  def disabled?
    driver.evaluate_script("arguments[0].matches(':disabled, select:disabled *')", self)
  end

  def select_option
    # To optimize to only one check and then click
    selected_or_disabled = driver.evaluate_script(<<~JS, self)
      arguments[0].matches(':disabled, select:disabled *, :checked')
    JS
    click unless selected_or_disabled
  end

  def visible?
    return super unless native_displayed?

    begin
      bridge.send(:execute, :is_element_displayed, id: native.ref)
    rescue Selenium::WebDriver::Error::UnknownCommandError
      # If the is_element_displayed command is unknown, no point in trying again
      driver.options[:native_displayed] = false
      super
    end
  end

private

  def perform_legacy_drag(element)
    return super if chromedriver_fixed_actions_key_state? || !w3c? || element.obscured?

    # W3C Chrome/chromedriver < 77 doesn't maintain mouse button state across actions API performs
    # https://bugs.chromium.org/p/chromedriver/issues/detail?id=2981
    browser_action.release.perform
    browser_action.click_and_hold(native).move_to(element.native).release.perform
  end

  def file_errors
    @file_errors = ::Selenium::WebDriver.logger.suppress_deprecations do
      [::Selenium::WebDriver::Error::ExpectedError]
    end
  end

  def w3c?
    (defined?(Selenium::WebDriver::VERSION) && (Selenium::WebDriver::VERSION.to_f >= 4)) ||
      capabilities.is_a?(::Selenium::WebDriver::Remote::W3C::Capabilities)
  end

  def browser_version(to_float = true)
    caps = capabilities
    ver = (caps[:browser_version] || caps[:version])
    ver = ver.to_f if to_float
    ver
  end

  def chromedriver_fixed_actions_key_state?
    Gem::Version.new(chromedriver_version) >= Gem::Version.new('76.0.3809.68')
  end

  def chromedriver_supports_displayed_endpoint?
    Gem::Version.new(chromedriver_version) >= Gem::Version.new('76.0.3809.25')
  end

  def chromedriver_version
    capabilities['chrome']['chromedriverVersion'].split(' ')[0]
  end

  def capabilities
    driver.browser.capabilities
  end

  def native_displayed?
    (driver.options[:native_displayed] != false) &&
      (w3c? && chromedriver_supports_displayed_endpoint?) &&
      (!ENV['DISABLE_CAPYBARA_SELENIUM_OPTIMIZATIONS'])
  end
end
