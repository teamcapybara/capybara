require 'selenium-webdriver'

module Selenium
  module WebDriver
    class Driver

      def get_alert_text
        bridge.getAlertText
      end

      def accept_alert
        bridge.acceptAlert
      end

      def dismiss_alert
        bridge.dismissAlert
      end
    end
  end
end