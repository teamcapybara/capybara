require 'sinatra/base'
require 'rack'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  get '/' do
    'Hello world!'
  end

  get '/foo' do
    'Another World'
  end
  
  get '/redirect' do
    redirect '/redirect_again'
  end

  get '/redirect_again' do
    redirect '/landed'
  end

  get '/landed' do
    "You landed"
  end
  
  get '/form/get' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end
  
  get '/favicon.ico' do
    nil
  end

  get '/:view' do |view|
    erb view.to_sym
  end

  post '/redirect' do
    redirect '/redirect_again'
  end

  post '/form' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  post '/upload' do
    params[:form][:document][:tempfile].read
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end
