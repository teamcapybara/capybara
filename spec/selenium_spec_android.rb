require "sauce_helper"
require 'spec_helper'

# Capybara.register_driver :selenium_android do |app|
#   # args = ENV['TRAVIS'] ? ['no-sandbox' ] : []
#   args = []
#   Capybara::Selenium::Driver.new(app, :browser => :android, :args => args)
# end

class AndroidTestApp < TestApp
  # Object.id is different from the TestApp used in firefox session so 
  # a new Capybar::Server instance will get launched for android testing
end

module TestSessions
  # Android = Capybara::Session.new(:selenium_android, AndroidTestApp)
  Android = Capybara::Session.new(:sauce, AndroidTestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Android, "selenium_android", 
  capybara_skip: [
    :response_headers,
    :status_code,
    :trigger ], capybara_only: [:touch], sauce: true unless ENV['TRAVIS'] && (RUBY_PLATFORM == 'java')
