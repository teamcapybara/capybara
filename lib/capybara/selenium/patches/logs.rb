# frozen_string_literal: true

module Capybara
  module Selenium
    module ChromeLogs
      LOG_MSG = <<~MSG
        Chromedriver 75+ defaults to W3C mode. The W3C webdriver spec does not define a method for accessing log types. \
        If you need to access the available log types, in the short term, you can configure you driver to not use the W3C mode. \
        This functionality will be returning in Chromedriver 76 or 77 in a W3C compatible way.
      MSG

      def method_missing(meth, *) # rubocop:disable Style/MissingRespondToMissing
        raise NotImplementedError, LOG_MSG if meth == :available_log_types

        super
      end

      COMMANDS = {
        # get_available_log_types: [:get, 'session/:session_id/log/types'],
        get_log: [:post, 'session/:session_id/log']
      }.freeze

      def commands(command)
        COMMANDS[command] || super
      end

      def log(type)
        data = execute :get_log, {}, type: type.to_s

        Array(data).map do |l|
          begin
            ::Selenium::WebDriver::LogEntry.new l.fetch('level', 'UNKNOWN'), l.fetch('timestamp'), l.fetch('message')
          rescue KeyError
            next
          end
        end
      end
    end
  end
end
