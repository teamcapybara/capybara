$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'capybara'
require 'test_app'
require 'drivers_spec'
require 'session_spec'
Dir[File.dirname(__FILE__)+'/dsl/*'].each { |group| 
  require group
}
require 'session_with_javascript_support_spec'
require 'session_without_javascript_support_spec'
require 'session_with_headers_support_spec'
require 'session_without_headers_support_spec'

alias :running :lambda

Capybara.default_wait_time = 1 # less timeout so tests run faster

Spec::Runner.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
end
