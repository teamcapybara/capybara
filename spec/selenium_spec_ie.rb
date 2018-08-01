# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

Capybara.register_driver :selenium_ie do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  Capybara::Selenium::Driver.new(
    app,
    browser: :ie,
    desired_capabilities: ::Selenium::WebDriver::Remote::Capabilities.ie('requireWindowFocus': true)
  )
end

module TestSessions
  SeleniumIE = Capybara::Session.new(:selenium_ie, TestApp)
end

skipped_tests = %i[response_headers status_code trigger modals hover form_attribute windows]

$stdout.puts `#{Selenium::WebDriver::IE.driver_path} --version` if ENV['CI']

TestSessions::SeleniumIE.current_window.resize_to(1600, 1200)

Capybara::SpecHelper.run_specs TestSessions::SeleniumIE, 'selenium', capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#refresh it reposts$/
    skip 'Firefox and Edge insist on prompting without providing a way to suppress'
  when /#click_link can download a file$/
    skip 'Not sure how to configure IE for automatic downloading'
  when /#fill_in with Date /
    pending "IE 11 doesn't support date input types"
  when /#click_link_or_button with :disabled option happily clicks on links which incorrectly have the disabled attribute$/
    pending 'IE 11 obeys non-standard disabled attribute on anchor tag'
  end
end

RSpec.describe 'Capybara::Session with Internet Explorer', capybara_skip: skipped_tests do
  include Capybara::SpecHelper
  include_examples 'Capybara::Session', TestSessions::SeleniumIE, :selenium_ie
  include_examples Capybara::RSpecMatchers, TestSessions::SeleniumIE, :selenium_ie
end
