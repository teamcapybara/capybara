$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'webcat'
require 'sinatra/base'
require 'rack'
require 'test_app'

alias :running :lambda
