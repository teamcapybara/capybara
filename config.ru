## This is not needed for Thin > 1.0.0
ENV['RACK_ENV'] = "production"

require File.expand_path('lib/capybara/spec/test_app', File.dirname(__FILE__))

run TestApp
