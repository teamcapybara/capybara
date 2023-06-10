# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'shared_selenium_node'
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
            "You can run a selenium server easily with: \n  " \
            '$ docker-compose up -d selenium_chrome'
    else
      puts 'Waiting for Selenium docker instance...'
      sleep 1
      retry
    end
  end
end

def selenium_gte?(version)
  defined?(Selenium::WebDriver::VERSION) && (Gem::Version.new(Selenium::WebDriver::VERSION) >= Gem::Version.new(version))
end

Capybara.register_driver :selenium_chrome_remote do |app|
  ensure_selenium_running!

  url = "http://#{selenium_host}:#{selenium_port}/wd/hub"
  browser_options = Selenium::WebDriver::Chrome::Options.new

  Capybara::Selenium::Driver.new app,
                                 browser: :remote,
                                 options: browser_options,
                                 url: url
end

CHROME_REMOTE_DRIVER = :selenium_chrome_remote

module TestSessions
  Chrome = Capybara::Session.new(CHROME_REMOTE_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger download]

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /Capybara::Session selenium_chrome_remote node #shadow_root should get visible text/
    pending "Selenium doesn't currently support getting visible text for shadow root elements"
  when /Capybara::Session selenium_chrome_remote node #shadow_root/
    skip 'Not supported with this chromedriver version' if chromedriver_lt?('96.0', @session)
  end
end

RSpec.describe 'Capybara::Session with remote Chrome' do
  include Capybara::SpecHelper
  ['Capybara::Session', 'Capybara::Node', Capybara::RSpecMatchers].each do |examples|
    include_examples examples, TestSessions::Chrome, CHROME_REMOTE_DRIVER
  end

  it 'is considered to be chrome' do
    expect(session.driver.browser.browser).to eq :chrome
  end

  describe 'log access' do
    let(:logs) do
      session.driver.browser.then do |chrome_driver|
        chrome_driver.respond_to?(:logs) ? chrome_driver : chrome_driver.manage
      end.logs
    end

    it 'does not error when getting log types' do
      expect do
        logs.available_types
      end.not_to raise_error
    end

    it 'does not error when getting logs' do
      expect do
        logs.get(:browser)
      end.not_to raise_error
    end
  end
end
