$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'capybara'
require 'test_app'
require 'drivers_spec'
require 'session_spec'

alias :running :lambda
