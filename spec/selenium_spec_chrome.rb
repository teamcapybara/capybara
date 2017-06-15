# frozen_string_literal: true
require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'

chrome_options = {
  browser: :chrome,
  options: ::Selenium::WebDriver::Chrome::Options.new(args: ENV['TRAVIS'] ? ['no-sandbox' ] : [])
}

if ENV['CAPYBARA_CHROME_HEADLESS']
  chrome_options[:options].args << 'headless'
  Selenium::WebDriver::Chrome.path='/usr/bin/google-chrome-beta' if ENV['TRAVIS']
end

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, chrome_options)
end

Capybara.register_driver :selenium_chrome_clear_storage do |app|
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_local_storage: true, clear_session_storage: true))
end

module TestSessions
  Chrome = Capybara::Session.new(:selenium_chrome, TestApp)
end

skipped_tests = [:response_headers, :status_code, :trigger]
skipped_tests << :windows if ENV['TRAVIS'] && ENV['SKIP_WINDOW']
# skip window tests when headless for now - closing a window not supported by chromedriver/chrome
skipped_tests << :windows if ENV['TRAVIS'] && ENV['CAPYBARA_CHROME_HEADLESS']

Capybara::SpecHelper.run_specs TestSessions::Chrome, "selenium_chrome", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with chrome" do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::Chrome, :selenium_chrome

  context "storage" do
    describe "#reset!" do
      it "does not clear either storage by default" do
        @session = TestSessions::Chrome
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        expect(@session.driver.browser.local_storage.keys).not_to be_empty
        expect(@session.driver.browser.session_storage.keys).not_to be_empty
      end

      it "clears storage when set" do
        @session = Capybara::Session.new(:selenium_chrome_clear_storage, TestApp)
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        expect(@session.driver.browser.local_storage.keys).to be_empty
        expect(@session.driver.browser.session_storage.keys).to be_empty
      end
    end
  end
end
