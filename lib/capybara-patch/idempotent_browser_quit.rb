module CapybaraPatch

  module IdempotentBrowserQuit
    # Quits the browser. Stores a boolean value +@quit+ to make the method
    # idempotent. In other words, if the browser is quit *before* the +at_exit+
    # hook, there are no negative effects from calling the method during the
    # +at_exit+ hook.
    def quit
      return unless @browser and not @quit

      @browser.quit
      @quit = true
    rescue Errno::ECONNREFUSED, ::Selenium::WebDriver::Error::UnknownError
      # Ignore this error. The browser may have already quit on its own.
    end

    def invalid_element_errors
      [::Selenium::WebDriver::Error::StaleElementReferenceError, ::Selenium::WebDriver::Error::UnknownError, ::Selenium::WebDriver::Error::ElementNotVisibleError, ::Selenium::WebDriver::Error::InvalidSelectorError]
    end
  end

end

module Capybara

  class Selenium::Driver < Driver::Base

    include CapybaraPatch::IdempotentBrowserQuit

  end

end
