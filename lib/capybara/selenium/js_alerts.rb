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
      
      def set_js_alert_text(text)
        bridge.setAlertValue(text)
      end
    end
  end
end