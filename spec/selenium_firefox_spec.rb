# frozen_string_literal: true
require 'spec_helper'
require "selenium-webdriver"
require 'shared_selenium_session'

Capybara.register_driver :selenium_focus do |app|
  # profile = Selenium::WebDriver::Firefox::Profile.new
  # profile["focusmanager.testmode"] = true
  # Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

module TestSessions
  Selenium = Capybara::Session.new(:selenium_focus, TestApp)
end

skipped_tests = [
  :response_headers,
  :status_code,
  :trigger
]
skipped_tests << :windows if ENV['TRAVIS'] && !ENV['WINDOW_TEST']

Capybara::SpecHelper.run_specs TestSessions::Selenium, "selenium", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with firefox" do
  include_examples  "Capybara::Session", TestSessions::Selenium, :selenium_focus
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
  end
end

