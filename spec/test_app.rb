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

  get '/with_html' do
    erb :with_html
  end
  
  get '/with_js' do
    erb :with_js
  end
  
  get '/with_simple_html' do
    erb :with_simple_html
  end

  get '/form' do
    erb :form
  end

  post '/redirect' do
    redirect '/redirect_again'
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

  post '/form' do
    params[:form].to_yaml
  end

  post '/upload' do
    params[:form][:document][:tempfile].read
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end
