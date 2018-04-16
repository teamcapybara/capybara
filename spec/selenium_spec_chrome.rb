# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

CHROME_DRIVER = ENV['HEADLESS'] ? :selenium_chrome_headless : :selenium_chrome

# if ENV['HEADLESS'] && ENV['TRAVIS']
#   Selenium::WebDriver::Chrome.path='/usr/bin/google-chrome-beta'
# end

Capybara.register_driver :selenium_chrome_clear_storage do |app|
  chrome_options = {
    browser: :chrome,
    options: ::Selenium::WebDriver::Chrome::Options.new
  }
  chrome_options[:options].args << 'headless' if ENV['HEADLESS']
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_local_storage: true, clear_session_storage: true))
end

module TestSessions
  Chrome = Capybara::Session.new(CHROME_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && (ENV['SKIP_WINDOW'] || ENV['HEADLESS'])

$stdout.puts `#{Selenium::WebDriver::Chrome.driver_path} --version` if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_DRIVER.to_s, capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with chrome" do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::Chrome, CHROME_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Chrome, CHROME_DRIVER

  context "storage" do
    describe "#reset!" do
      it "does not clear either storage by default" do
        @session = TestSessions::Chrome
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        # expect(@session.driver.browser.local_storage.keys).not_to be_empty
        # expect(@session.driver.browser.session_storage.keys).not_to be_empty
        expect(@session.evaluate_script('Object.keys(localStorage)')).not_to be_empty
        expect(@session.evaluate_script('Object.keys(sessionStorage)')).not_to be_empty
      end

      it "clears storage when set" do
        @session = Capybara::Session.new(:selenium_chrome_clear_storage, TestApp)
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        # expect(@session.driver.browser.local_storage.keys).to be_empty
        # expect(@session.driver.browser.session_storage.keys).to be_empty
        expect(@session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(@session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end
    end
  end
end
