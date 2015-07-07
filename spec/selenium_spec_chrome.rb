require 'spec_helper'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome do |app|
  args = ENV['TRAVIS'] ? ['no-sandbox' ] : []
  Capybara::Selenium::Driver.new(app, :browser => :chrome, :args => args)
end

module TestSessions
  Chrome = Capybara::Session.new(:selenium_chrome, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Chrome, "selenium_chrome", :capybara_skip => [
  :response_headers,
  :status_code,
  :trigger
  ] unless ENV['TRAVIS'] && (RUBY_PLATFORM == 'java')
