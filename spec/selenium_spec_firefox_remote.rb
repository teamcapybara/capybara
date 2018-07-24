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
  timer = Capybara::Helpers.timer(expire_in: 20)
  begin
    TCPSocket.open(selenium_host, selenium_port)
  rescue StandardError
    if timer.expired?
      raise 'Selenium is not running. ' \
          "You can run a selenium server easily with: \n" \
          '  $ docker-compose up -d selenium_firefox'
    else
      puts 'Waiting for Selenium docker instance...'
      sleep 1
      retry
    end
  end
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
  RemoteFirefox = Capybara::Session.new(FIREFOX_REMOTE_DRIVER, TestApp)
end

TestSessions::RemoteFirefox.driver.browser.file_detector = lambda do |args|
  # args => ["/path/to/file"]
  str = args.first.to_s
  str if File.exist?(str)
end

skipped_tests = %i[response_headers status_code trigger download]
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && (ENV['SKIP_WINDOW'] || ENV['HEADLESS'])

Capybara::SpecHelper.run_specs TestSessions::RemoteFirefox, FIREFOX_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when 'Capybara::Session selenium_firefox_remote node #send_keys should generate key events',
       'Capybara::Session selenium_firefox_remote node #send_keys should allow for multiple simultaneous keys',
       'Capybara::Session selenium_firefox_remote node #send_keys should send special characters'
    pending "selenium-webdriver/geckodriver doesn't support complex sets of characters"
  when 'Capybara::Session selenium_firefox_remote node #click should allow multiple modifiers'
    pending "Firefox doesn't generate an event for shift+control+click" if marionette_gte?(62, @session)
  when /^Capybara::Session selenium node #double_click/
    pending "selenium-webdriver/geckodriver doesn't generate double click event" if marionette_lt?(59, @session)
  when 'Capybara::Session selenium_firefox_remote #refresh it reposts'
    skip 'Firefox insists on prompting without providing a way to suppress'
  when 'Capybara::Session selenium_firefox_remote #accept_prompt should accept the prompt with a blank response when there is a default'
    pending "Geckodriver doesn't set a blank response currently"
  when 'Capybara::Session selenium_firefox_remote #attach_file with multipart form should fire change once for each set of files uploaded',
       'Capybara::Session selenium_firefox_remote #attach_file with multipart form should fire change once when uploading multiple files from empty'
    pending 'Due to having to work around selenium remote lack of multiple file upload support the change event count is off'
  end
end

RSpec.describe 'Capybara::Session with remote firefox' do
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::RemoteFirefox, FIREFOX_REMOTE_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::RemoteFirefox, FIREFOX_REMOTE_DRIVER

  it 'is considered to be firefox' do
    expect(session.driver.send(:firefox?)).to be_truthy
    expect(session.driver.send(:marionette?)).to be_truthy
  end
end
