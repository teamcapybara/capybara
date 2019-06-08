# frozen_string_literal: true

require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::EdgeNode < Capybara::Selenium::Node
  include Html5Drag

  def set_text(value, clear: nil, **_unused)
    return super unless chrome_edge?

    super.tap do
      # React doesn't see the chromedriver element clear
      send_keys(:space, :backspace) if value.to_s.empty? && clear.nil?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    # In Chrome 75+ files are appended (due to WebDriver spec - why?) so we have to clear here if its multiple and already set
    if chrome_edge?
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
    return super unless chrome_edge?

    html5_drop(*args)
  end

  # def click(*)
  #   super
  # rescue ::Selenium::WebDriver::Error::WebDriverError => e
  #   # chromedriver 74 (at least on mac) raises the wrong error for this
  #   raise ::Selenium::WebDriver::Error::ElementClickInterceptedError, e.message if e.message.match?(/element click intercepted/)
  #
  #   raise
  # end

  def disabled?
    return super unless chrome_edge?

    driver.evaluate_script("arguments[0].matches(':disabled, select:disabled *')", self)
  end

  def select_option
    return super unless chrome_edge?

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

  def browser_version
    @browser_version ||= begin
      caps = driver.browser.capabilities
      (caps[:browser_version] || caps[:version]).to_f
    end
  end

  def chrome_edge?
    browser_version >= 75
  end
end
