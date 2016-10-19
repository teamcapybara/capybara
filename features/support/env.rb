# frozen_string_literal: true
require 'rubygems'
require 'bundler/setup'

require 'capybara/cucumber'
require 'capybara/spec/test_app'

Capybara.app = TestApp

# These drivers are only used for testing driver switching.
# They don't actually need to process javascript so use RackTest

Capybara.register_driver :javascript_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.javascript_driver = :javascript_test

Capybara.register_driver :named_test do |app|
  Capybara::RackTest::Driver.new(app)
end

