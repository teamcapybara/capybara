require 'capybara/spec/test_app'
require 'capybara/spec/spec_helper'
require 'nokogiri'

Dir[File.dirname(__FILE__)+'/session/*'].each { |group| require group }
