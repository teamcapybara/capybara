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
    super(value)
  rescue *file_errors => e
    raise ArgumentError, "Selenium < 3.14 with remote Chrome doesn't support multiple file upload" if e.message.match?(/File not found : .+\n.+/m)

    raise
  end

  def drag_to(element)
    return super unless html5_draggable?

    html5_drag_to(element)
  end

  def drop(*args)
    html5_drop(*args)
  end

  def click(*)
    super
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

private

  def file_errors
    @file_errors = ::Selenium::WebDriver.logger.suppress_deprecations do
      [::Selenium::WebDriver::Error::ExpectedError]
    end
  end

  def bridge
    driver.browser.send(:bridge)
  end

  def w3c?
    (defined?(Selenium::WebDriver::VERSION) && (Selenium::WebDriver::VERSION.to_f >= 4)) ||
      driver.browser.capabilities.is_a?(::Selenium::WebDriver::Remote::W3C::Capabilities)
  end

  def browser_version
    caps = driver.browser.capabilities
    (caps[:browser_version] || caps[:version]).to_f
  end
end
