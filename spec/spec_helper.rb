require 'capybara/spec/spec_helper'

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
end
