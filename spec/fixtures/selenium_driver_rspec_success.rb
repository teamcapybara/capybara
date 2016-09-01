# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Selenium::Driver do
  it "should exit with a zero exit status" do
    browser = Capybara::Selenium::Driver.new(TestApp, browser: (ENV['SELENIUM_BROWSER'] || :firefox).to_sym).browser
    expect(true).to eq(true)
  end
end
