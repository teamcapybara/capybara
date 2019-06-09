# frozen_string_literal: true

module Capybara
  module Selenium
    module ChromeLogs
      LOG_MSG = <<~MSG
        Chromedriver 75+ defaults to W3C mode. The W3C webdriver spec does not define methods for accessing \
        logs or log types. If you need to access the logs, in the short term, you can configure you driver to not use the W3C mode. \
        It is unknown how long non-W3C mode will be supported by chromedriver (it won't be supported by selenium-webdriver 4+) \
        so you may need to consider other solutions in the near future.
      MSG

      def method_missing(meth, *) # rubocop:disable Style/MissingRespondToMissing
        raise NotImplementedError, LOG_MSG if %i[available_log_types log].include? meth

        super
      end
    end
  end
end
