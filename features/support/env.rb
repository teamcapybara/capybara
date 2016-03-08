# frozen_string_literal: true
require 'rubygems'
require 'bundler/setup'

require 'capybara/cucumber'
require 'capybara/spec/test_app'

Capybara.app = TestApp
