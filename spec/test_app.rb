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

  post '/form' do
    params[:form].to_yaml
  end
end
