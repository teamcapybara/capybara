# frozen_string_literal: true

module PauseDurationFix
  def encode
    super.tap { |output| output[:duration] ||= 0 }
  end
end

if defined?(::Selenium::WebDriver::Interactions::Pause)
  ::Selenium::WebDriver::Interactions::Pause.prepend PauseDurationFix
end
