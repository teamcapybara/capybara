# frozen_string_literal: true
require 'spec_helper'
require "selenium-webdriver"
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

Capybara.register_driver :selenium_marionette do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true)
  )
end

Capybara.register_driver :selenium_marionette_clear_storage do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true),
    clear_local_storage: true,
    clear_session_storage: true
  )
end

module TestSessions
  SeleniumMarionette = Capybara::Session.new(:selenium_marionette, TestApp)
end

skipped_tests = [
  :response_headers,
  :status_code,
  :trigger
]
skipped_tests << :windows if ENV['TRAVIS'] && !ENV['WINDOW_TEST']

Capybara::SpecHelper.run_specs TestSessions::SeleniumMarionette, "selenium", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with firefox" do
  include_examples  "Capybara::Session", TestSessions::SeleniumMarionette, :selenium_marionette
  include_examples  Capybara::RSpecMatchers, TestSessions::SeleniumMarionette, :selenium_marionette
end

RSpec.describe Capybara::Selenium::Driver do
  before do
    @driver = Capybara::Selenium::Driver.new(TestApp, browser: :firefox)
  end

  describe '#quit' do
    it "should reset browser when quit" do
      expect(@driver.browser).to be
      @driver.quit
      #access instance variable directly so we don't create a new browser instance
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end

    it "ignores an error communicating with browser because it is probably already gone" do
      allow(@driver.browser).to(
        receive(:quit)
        .and_raise(Selenium::WebDriver::Error::UnknownError, described_class::CONNECTION_ERROR_TEXT_MARIONETTE)
      )

      expect {
        @driver.quit
      }.not_to raise_error
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end

    it "does not ignore other errors" do
      allow(@driver.browser).to(
        receive(:quit)
        .and_raise(Selenium::WebDriver::Error::UnknownError, 'alarm!')
      )

      expect {
        @driver.quit
      }.to raise_error(Selenium::WebDriver::Error::UnknownError, 'alarm!')
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end
  end

  context "storage" do
    describe "#reset!" do
      it "does not clear either storage by default" do
        @session = TestSessions::SeleniumMarionette
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        expect(@session.driver.browser.local_storage.keys).not_to be_empty
        expect(@session.driver.browser.session_storage.keys).not_to be_empty
      end

      it "clears storage when set" do
        @session = Capybara::Session.new(:selenium_marionette_clear_storage, TestApp)
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

