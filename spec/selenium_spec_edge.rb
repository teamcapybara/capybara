# frozen_string_literal: true

require 'spec_helper'
require "selenium-webdriver"
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

Capybara.register_driver :selenium_edge do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  Capybara::Selenium::Driver.new(app, browser: :edge)
end

module TestSessions
  SeleniumEdge = Capybara::Session.new(:selenium_edge, TestApp)
end

skipped_tests = %i[response_headers status_code trigger modals]

$stdout.puts `#{Selenium::WebDriver::Edge.driver_path} --version` if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::SeleniumEdge, "selenium", capybara_skip: skipped_tests

RSpec.describe "Capybara::Session with Edge", capybara_skip: skipped_tests do
  include Capybara::SpecHelper
  include_examples  "Capybara::Session", TestSessions::SeleniumEdge, :selenium_edge
  include_examples  Capybara::RSpecMatchers, TestSessions::SeleniumEdge, :selenium_edge
end
