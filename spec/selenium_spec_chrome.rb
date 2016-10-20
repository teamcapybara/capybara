# frozen_string_literal: true
require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'

Capybara.register_driver :selenium_chrome do |app|
  args = ENV['TRAVIS'] ? ['no-sandbox' ] : []
  Capybara::Selenium::Driver.new(app, :browser => :chrome, :args => args)
end

module TestSessions
  Chrome = Capybara::Session.new(:selenium_chrome, TestApp)
end

skipped_tests = [:response_headers, :status_code, :trigger]
skipped_tests << :windows if ENV['TRAVIS'] && !ENV['WINDOW_TEST']

Capybara::SpecHelper.run_specs TestSessions::Chrome, "selenium_chrome", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with chrome" do
  include_examples  "Capybara::Session", TestSessions::Chrome, :selenium_chrome
end
