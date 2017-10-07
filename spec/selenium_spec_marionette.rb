# frozen_string_literal: true
require 'spec_helper'
require "selenium-webdriver"
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

browser_options = ::Selenium::WebDriver::Firefox::Options.new()
browser_options.args << '--headless' if ENV['HEADLESS']
browser_options.add_preference 'dom.file.createInChild', true
# browser_options.add_option("log", {"level": "trace"})

Capybara.register_driver :selenium_marionette do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: {marionette: true, 'moz:webdriverClick': true},
    options: browser_options
    # Get a trace level log from geckodriver
    # :driver_opts => { args: ['-vv'] }
  )
end

Capybara.register_driver :selenium_marionette_clear_storage do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: {marionette: true},
    clear_local_storage: true,
    clear_session_storage: true,
    options: browser_options
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
skipped_tests << :windows if ENV['TRAVIS'] && ENV['SKIP_WINDOW']

Capybara::SpecHelper.run_specs TestSessions::SeleniumMarionette, "selenium", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with firefox" do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::SeleniumMarionette, :selenium_marionette
  include_examples  Capybara::RSpecMatchers, TestSessions::SeleniumMarionette, :selenium_marionette
end

RSpec.describe Capybara::Selenium::Driver do
  before do
    @driver = Capybara::Selenium::Driver.new(TestApp, browser: :firefox, options: browser_options)
  end

  describe '#quit' do
    it "should reset browser when quit" do
      expect(@driver.browser).to be
      @driver.quit
      #access instance variable directly so we don't create a new browser instance
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end

    context "with errors" do
      before do
        @original_browser = @driver.browser
      end
      after do
        # Ensure browser is actually quit so we don't leave hanging processe
        RSpec::Mocks.space.proxy_for(@original_browser).reset
        @original_browser.quit
      end

      it "warns UnknownError returned during quit because the browser is probably already gone" do
        expect_any_instance_of(Capybara::Selenium::Driver).to receive(:warn).with(/random message/)
        allow(@driver.browser).to(
          receive(:quit)
          .and_raise(Selenium::WebDriver::Error::UnknownError, "random message")
        )

        expect { @driver.quit }.not_to raise_error
        expect(@driver.instance_variable_get(:@browser)).to be_nil
      end

      it "ignores silenced UnknownError returned during quit because the browser is almost definitely already gone" do
        expect_any_instance_of(Capybara::Selenium::Driver).not_to receive(:warn)
        allow(@driver.browser).to(
          receive(:quit)
          .and_raise(Selenium::WebDriver::Error::UnknownError, "Error communicating with the remote browser")
        )

        expect { @driver.quit }.not_to raise_error
        expect(@driver.instance_variable_get(:@browser)).to be_nil
      end
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

