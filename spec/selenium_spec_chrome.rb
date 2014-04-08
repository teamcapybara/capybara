require 'spec_helper'

Capybara.register_driver :selenium_chrome do |app|
  args = ENV['TRAVIS'] ? ['no-sandbox' ] : []
  Capybara::Selenium::Driver.new(app, :browser => :chrome, :args => args)
end

class ChromeTestApp < TestApp
  # Object.id is different from the TestApp used in firefox session so 
  # a new Capybara::Server instance will get launched for chrome testing
end

module TestSessions
  Chrome = Capybara::Session.new(:selenium_chrome, ChromeTestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Chrome, "selenium_chrome", :capybara_skip => [
  :response_headers,
  :status_code,
  :trigger,
  :touch  
  ] unless ENV['TRAVIS'] && (RUBY_PLATFORM == 'java')
