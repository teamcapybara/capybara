# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'shared_selenium_node'
require 'rspec/shared_spec_matchers'

Selenium::WebDriver::Edge::Service.driver_path = '/usr/local/bin/msedgedriver'
Selenium::WebDriver::EdgeChrome.path = '/Applications/Microsoft Edge Canary.app/Contents/MacOS/Microsoft Edge Canary'

Capybara.register_driver :selenium_edge do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  Capybara::Selenium::Driver.new(app, browser: :edge_chrome).tap do |driver|
    driver.browser
    driver.download_path = Capybara.save_path
  end
end

module TestSessions
  SeleniumEdge = Capybara::Session.new(:selenium_edge, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]

Capybara::SpecHelper.log_selenium_driver_version(Selenium::WebDriver::Edge) if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::SeleniumEdge, 'selenium', capybara_skip: skipped_tests do |example|
  # case example.metadata[:description]
  # when /#refresh it reposts$/
  #   skip 'Edge insists on prompting without providing a way to suppress'
  # when /should be able to open non-http url/
  #   skip 'Crashes'
  # when /when Capybara.always_include_port is true/
  #   skip 'Crashes'
  # end
end

RSpec.describe 'Capybara::Session with Edge', capybara_skip: skipped_tests do
  include Capybara::SpecHelper
  ['Capybara::Session', 'Capybara::Node', Capybara::RSpecMatchers].each do |examples|
    include_examples examples, TestSessions::SeleniumEdge, :selenium_edge
  end
end
