# frozen_string_literal: true
require 'rspec/expectations'
require "capybara/spec/spec_helper"
require "pry"

RSpec.configure do |config|
  Capybara::SpecHelper.configure(config)
end
