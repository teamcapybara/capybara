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
  rescue ::Selenium::WebDriver::Error::ExpectedError => err
    if err.message =~ /File not found : .+\n.+/m
      raise ArgumentError, "Selenium < 3.14 with remote Chrome doesn't support multiple file upload"
    end

    raise
  end

  def drag_to(element)
    return super unless html5_draggable?

    html5_drag_to(element)
  end

private

  def bridge
    driver.browser.send(:bridge)
  end
end
