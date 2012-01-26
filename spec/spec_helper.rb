$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'
require "bundler/setup"

require 'rspec'
require 'capybara'

RSpec.configure do |config|
  config.before do
    Capybara.configure do |config|
      config.default_selector = :xpath
    end
  end

  # Workaround for http://code.google.com/p/selenium/issues/detail?id=3147:
  # Rerun the example if we hit a transient "docElement is null" error
  config.around(:each) do |example|
    attempts = 0
    begin
      example.run
      e = @example.instance_variable_get('@exception') # usually nil
      if (e.is_a?(Selenium::WebDriver::Error::UnknownError) &&
          e.message == 'docElement is null' && (attempts += 1) < 5)
        @example.instance_variable_set('@exception', nil)
        redo
      end
    end until true
  end
end

# Required here instead of in rspec_spec to avoid RSpec deprecation warning
require 'capybara/rspec'

require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.app = TestApp
Capybara.default_wait_time = 0 # less timeout so tests run faster

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
end