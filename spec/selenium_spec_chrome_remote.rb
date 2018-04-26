# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

def selenium_host
  ENV.fetch('SELENIUM_HOST', '0.0.0.0')
end

def selenium_port
  ENV.fetch('SELENIUM_PORT', 4444)
end

def ensure_selenium_running!
  TCPSocket.open(selenium_host, selenium_port)
rescue
  raise 'Selenium is not running. ' \
        "You can run a selenium server easily with: \n" \
        '  $ docker-compose up -d selenium'
end

Capybara.register_driver :selenium_chrome_remote do |app|
  ensure_selenium_running!

  url = "http://#{selenium_host}:#{selenium_port}/wd/hub"
  caps = Selenium::WebDriver::Remote::Capabilities.chrome

  Capybara::Selenium::Driver.new app,
                                 browser: :remote,
                                 desired_capabilities: caps,
                                 url: url
end

CHROME_REMOTE_DRIVER = :selenium_chrome_remote

module TestSessions
  Chrome = Capybara::Session.new(CHROME_REMOTE_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && (ENV['SKIP_WINDOW'] || ENV['HEADLESS'])

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with chrome" do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::Chrome, CHROME_REMOTE_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Chrome, CHROME_REMOTE_DRIVER

  it 'is considered to be chrome' do
    expect(session.driver).to be_chrome
  end
end
