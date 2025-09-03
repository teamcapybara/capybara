# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'

CHROME_VERSIONS = %w[135 136 138 139].freeze

Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome-beta' if ENV.fetch('CI', nil) && ENV.fetch('CHROME_BETA', nil)

Selenium::WebDriver.logger.ignore(:selenium_manager)

def build_driver(chrome_version)
  Capybara.register_driver :"chrome_#{chrome_version}" do |app|
    browser_options = Selenium::WebDriver::Chrome::Options.new
    browser_options.unhandled_prompt_behavior = :ignore
    browser_options.browser_version = chrome_version
    browser_options.web_socket_url = true

    version = Capybara::Selenium::Driver.load_selenium
    options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
    driver_options = { browser: :chrome, timeout: 5 }
    driver_options[options_key] = browser_options

    Capybara::Selenium::Driver.new(app, **driver_options)
  end
end

CHROME_VERSIONS.each do |version|
  build_driver(version)
end

Capybara::SpecHelper.log_selenium_driver_version(Selenium::WebDriver::Chrome) if ENV['CI']

RSpec.shared_examples 'beforeunload checks' do |session|
  it "#{session.mode} should accept browser modal", requires: [:modals] do
    session.visit('/with_unload_alert')
    session.fill_in 'data', with: 'this is data'
    session.accept_confirm do
      session.click_link('Go away')
    end
    expect(session).to have_text('Hello world')
  end
end

RSpec.describe 'testing with' do
  include Capybara::SpecHelper

  CHROME_VERSIONS.each do |version|
    include_examples 'beforeunload checks', Capybara::Session.new(:"chrome_#{version}", TestApp)
  end
end
