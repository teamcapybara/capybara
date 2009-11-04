class TestApp < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/views'

  get '/' do
    'Hello world!'
  end

  get '/foo' do
    'Another World'
  end
  
  get '/with_simple_html' do
    erb :with_simple_html
  end
end