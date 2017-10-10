# frozen_string_literal: true
require 'spec_helper'
require 'selenium-webdriver'

RSpec.describe Capybara::Selenium::Driver do
  it "should exit with a zero exit status" do
    options = { browser: (ENV['SELENIUM_BROWSER'] || :firefox).to_sym }
    options[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false) if ENV['LEGACY_FIREFOX']
    Capybara::Selenium::Driver.new(TestApp, options ).browser
    expect(true).to eq(true)
  end
end
