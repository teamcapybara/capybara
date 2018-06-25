# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

def selenium_host
  ENV.fetch('SELENIUM_HOST', '0.0.0.0')
end

def selenium_port
  ENV.fetch('SELENIUM_PORT', 4445)
end

def ensure_selenium_running!
  TCPSocket.open(selenium_host, selenium_port)
rescue
  raise 'Selenium is not running. ' \
        "You can run a selenium server easily with: \n" \
        '  $ docker-compose up -d selenium'
end

Capybara.register_driver :selenium_firefox_remote do |app|
  ensure_selenium_running!

  url = "http://#{selenium_host}:#{selenium_port}/wd/hub"
  caps = Selenium::WebDriver::Remote::Capabilities.firefox

  Capybara::Selenium::Driver.new app,
                                 browser: :remote,
                                 desired_capabilities: caps,
                                 url: url
end

FIREFOX_REMOTE_DRIVER = :selenium_firefox_remote

module TestSessions
  Firefox = Capybara::Session.new(FIREFOX_REMOTE_DRIVER, TestApp)
end

TestSessions::Firefox.driver.browser.file_detector = lambda do |args|
  # args => ["/path/to/file"]
  str = args.first.to_s
  str if File.exist?(str)
end

skipped_tests = %i[response_headers status_code trigger download]
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && (ENV['SKIP_WINDOW'] || ENV['HEADLESS'])

Capybara::SpecHelper.run_specs TestSessions::Firefox, FIREFOX_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with remote firefox" do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::Firefox, FIREFOX_REMOTE_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Firefox, FIREFOX_REMOTE_DRIVER

  it 'is considered to be firefox' do
    expect(session.driver.send(:firefox?)).to be_truthy
    expect(session.driver.send(:marionette?)).to be_truthy
  end
end
