$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'rubygems'
require 'webcat'
require 'sinatra/base'
require 'rack'

alias :running :lambda

class TestApp < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  get '/foo' do
    'Another World'
  end
end
