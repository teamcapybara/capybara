# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

Capybara.register_driver :selenium_ie do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  options = ::Selenium::WebDriver::IE::Options.new
  options.require_window_focus = true
  Capybara::Selenium::Driver.new(
    app,
    browser: :ie,
    desired_capabilities: ::Selenium::WebDriver::Remote::Capabilities.ie,
    options: options
  )
end

module TestSessions
  SeleniumIE = Capybara::Session.new(:selenium_ie, TestApp)
end

TestSessions::SeleniumIE.current_window.resize_to(800, 500)

skipped_tests = %i[response_headers status_code trigger modals hover form_attribute windows]

$stdout.puts `#{Selenium::WebDriver::IE.driver_path} --version` if ENV['CI']

TestSessions::SeleniumIE.current_window.resize_to(1600, 1200)

Capybara::SpecHelper.run_specs TestSessions::SeleniumIE, 'selenium', capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#refresh it reposts$/
    skip 'IE insists on prompting without providing a way to suppress'
  when /#click_link can download a file$/
    skip 'Not sure how to configure IE for automatic downloading'
  when /#fill_in with Date /
    pending "IE 11 doesn't support date input types"
  when /#click_link_or_button with :disabled option happily clicks on links which incorrectly have the disabled attribute$/
    skip 'IE 11 obeys non-standard disabled attribute on anchor tag'
  when /#right_click should allow modifiers$/
    skip "Windows can't :meta click because :meta triggers start menu"
  when /#click should allow multiple modifiers$/
    skip "Windows can't :meta click because :meta triggers start menu"
  when /#double_click should allow multiple modifiers$/
    skip "Windows can't :alt double click due to being properties shortcut"
  when /via clicking the wrapping label if possible$/
    pending 'IEDriver has an issue with the click location of elements with multiple children if the first child is a text node and the page is scrolled'
  end
end

RSpec.describe 'Capybara::Session with Internet Explorer', capybara_skip: skipped_tests do # rubocop:disable RSpec/MultipleDescribes
  include Capybara::SpecHelper
  include_examples 'Capybara::Session', TestSessions::SeleniumIE, :selenium_ie
  include_examples Capybara::RSpecMatchers, TestSessions::SeleniumIE, :selenium_ie
end

RSpec.describe Capybara::Selenium::Node do
  it '#right_click should allow modifiers' do
    session = TestSessions::SeleniumIE
    session.visit('/with_js')
    session.find(:css, '#click-test').right_click(:control)
    expect(session).to have_link('Has been control right clicked')
  end

  it '#click should allow multiple modifiers' do
    session = TestSessions::SeleniumIE
    session.visit('with_js')
    # IE triggers system behavior with :meta so can't use those here
    session.find(:css, '#click-test').click(:ctrl, :shift, :alt)
    expect(session).to have_link('Has been alt control shift clicked')
  end

  it '#double_click should allow modifiers' do
    session = TestSessions::SeleniumIE
    session.visit('/with_js')
    session.find(:css, '#click-test').double_click(:shift)
    expect(session).to have_link('Has been shift double clicked')
  end
end
