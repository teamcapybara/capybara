# frozen_string_literal: true
require 'rspec/expectations'
require "capybara/spec/spec_helper"
require 'webdrivers' if ENV['TRAVIS']

RSpec.configure do |config|
  Capybara::SpecHelper.configure(config)
  config.filter_run_including focus_: true unless ENV['TRAVIS']
  config.run_all_when_everything_filtered = true
end
