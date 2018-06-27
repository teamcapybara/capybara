# frozen_string_literal: true

class Capybara::Selenium::ChromeNode < Capybara::Selenium::Node
  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    super(value)
  rescue ::Selenium::WebDriver::Error::ExpectedError => e
    if e.message =~ /File not found : .+\n.+/m
      raise ArgumentError, "Selenium with remote Chrome doesn't currently support multiple file upload"
    end
    raise
  end

private

  def bridge
    driver.browser.send(:bridge)
  end
end
