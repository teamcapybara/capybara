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
end

# Required here instead of in rspec_spec to avoid RSpec deprecation warning
require 'capybara/rspec'

require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
end