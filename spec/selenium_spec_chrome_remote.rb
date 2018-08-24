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
  timer = Capybara::Helpers.timer(expire_in: 20)
  begin
    TCPSocket.open(selenium_host, selenium_port)
  rescue StandardError
    if timer.expired?
      raise 'Selenium is not running. ' \
          "You can run a selenium server easily with: \n" \
          '  $ docker-compose up -d selenium_chrome'
    else
      puts 'Waiting for Selenium docker instance...'
      sleep 1
      retry
    end
  end
end

def selenium_gte?(version)
  defined?(Selenium::WebDriver::VERSION) && (Selenium::WebDriver::VERSION.to_f >= version)
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

TestSessions::Chrome.driver.browser.file_detector = lambda do |args|
  # args => ["/path/to/file"]
  str = args.first.to_s
  str if File.exist?(str)
end

skipped_tests = %i[response_headers status_code trigger download]
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && (ENV['SKIP_WINDOW'] || ENV['HEADLESS'])

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when 'Capybara::Session selenium_chrome_remote #attach_file with multipart form should not break when using HTML5 multiple file input uploading multiple files',
       'Capybara::Session selenium_chrome_remote #attach_file with multipart form should fire change once for each set of files uploaded',
       'Capybara::Session selenium_chrome_remote #attach_file with multipart form should fire change once when uploading multiple files from empty'
    pending "Selenium with Remote Chrome doesn't support multiple file upload" unless selenium_gte?(3.14)
  end
end

RSpec.describe 'Capybara::Session with remote Chrome' do
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::Chrome, CHROME_REMOTE_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Chrome, CHROME_REMOTE_DRIVER

  it 'is considered to be chrome' do
    expect(session.driver.browser.browser).to eq :chrome
  end
end
