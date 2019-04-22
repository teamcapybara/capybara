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
    super(value)
  rescue *file_errors => e
    raise ArgumentError, "Selenium < 3.14 with remote Chrome doesn't support multiple file upload" if e.message.match?(/File not found : .+\n.+/m)

    raise
  end

  def drag_to(element)
    return super unless html5_draggable?

    html5_drag_to(element)
  end

  def click(*)
    super
  rescue ::Selenium::WebDriver::Error::WebDriverError => e
    # chromedriver 74 (at least on mac) raises the wrong error for this
    raise ::Selenium::WebDriver::Error::ElementClickInterceptedError, e.message if e.message.match?(/element click intercepted/)

    raise
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
end
