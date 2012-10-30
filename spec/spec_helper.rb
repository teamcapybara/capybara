$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'
require "bundler/setup"

require 'rspec'
require 'capybara'

RSpec.configure do |config|
  # Workaround for http://code.google.com/p/selenium/issues/detail?id=3147:
  # Rerun the example if we hit a transient "docElement is null" error
  config.around(:each) do |example|
    attempts = 0
    begin
      example.run
      # example is just a Proc, @example is the current RSpec::Core::Example
      e = @example.instance_variable_get('@exception') # usually nil
      if (defined?(Selenium::WebDriver::Error::UnknownError) && e.is_a?(Selenium::WebDriver::Error::UnknownError) &&
          e.message == 'docElement is null' && (attempts += 1) < 5)
        @example.instance_variable_set('@exception', nil)
        redo
      end
    end until true
  end
end

require 'capybara/spec/spec_helper'

alias :running :lambda

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
end
