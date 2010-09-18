$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'
require "bundler/setup"

require 'rspec'
require 'capybara'
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
  Selenium = Capybara::Session.new(:selenium, TestApp)
  Culerity = Capybara::Session.new(:culerity, TestApp)
  Celerity = Capybara::Session.new(:celerity, TestApp)
end

RSpec.configure do |config|

  running_with_jruby = RUBY_PLATFORM =~ /java/
  jruby_installed = `which jruby` && $?.success?

  warn "** Skipping Celerity specs because platform is not Java" unless running_with_jruby
  warn "** Skipping Culerity specs because JRuby is not installed" unless jruby_installed

  config.filter_run_excluding(:jruby => lambda { |value|
    return true if value == :platform && !running_with_jruby
    return true if value == :installed && !jruby_installed
  })

  config.before do
    Capybara.configure do |config|
      config.default_selector = :xpath
    end
  end
end
