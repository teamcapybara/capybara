# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'

RSpec.describe Capybara::Selenium::Driver do
  it 'should exit with a non-zero exit status' do
    options = { browser: (ENV['SELENIUM_BROWSER'] || :firefox).to_sym }
    browser = Capybara::Selenium::Driver.new(TestApp, options).browser
    expect(browser).to be_truthy
    expect(true).to eq(false) # rubocop:disable RSpec/ExpectActual
  end
end
