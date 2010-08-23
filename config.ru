ENV['RACK_ENV'] = "production"

require 'rubygems'
require 'bundler/setup'
require File.expand_path('lib/capybara/spec/test_app', File.dirname(__FILE__))

run TestApp
