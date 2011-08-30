require 'sinatra/base'
require 'rack'
require 'yaml'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  get '/' do
    'Hello world! <a href="with_html">Relative</a>'
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

  get '/host' do
    "Current host is #{request.scheme}://#{request.host}"
  end

  get '/redirect/:times/times' do
    times = params[:times].to_i
    if times.zero?
      "redirection complete"
    else
      redirect "/redirect/#{times - 1}/times"
    end
  end

  get '/landed' do
    "You landed"
  end

  get '/with-quotes' do
    %q{"No," he said, "you can't do that."}
  end

  get '/form/get' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  post '/relative' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  get '/favicon.ico' do
    nil
  end

  post '/redirect' do
    redirect '/redirect_again'
  end

  delete "/delete" do
    "The requested object was deleted"
  end

  get "/delete" do
    "Not deleted"
  end

  get '/redirect_back' do
    redirect back
  end

  get '/redirect_secure' do
    redirect "https://#{request.host}/host"
  end

  get '/slow_response' do
    sleep 2
    'Finally!'
  end

  get '/set_cookie' do
    cookie_value = 'test_cookie'
    response.set_cookie('capybara', cookie_value)
    "Cookie set to #{cookie_value}"
  end

  get '/get_cookie' do
    request.cookies['capybara']
  end

  get '/get_header' do
    env['HTTP_FOO']
  end

  get '/get_header_via_redirect' do
    redirect '/get_header'
  end

  get '/:view' do |view|
    erb view.to_sym
  end

  post '/form' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  post '/upload_empty' do
    if params[:form][:file].nil?
      'Successfully ignored empty file field.'
    else
      'Something went wrong.'
    end
  end

  post '/upload' do
    begin
      buffer = []
      buffer << "Content-type: #{params[:form][:document][:type]}"
      buffer << "File content: #{params[:form][:document][:tempfile].read}"
      buffer.join(' | ')
    rescue
      'No file uploaded'
    end
  end

  post '/upload_multiple' do
    begin
      buffer = []
      buffer << "Content-type: #{params[:form][:multiple_documents][0][:type]}"
      buffer << "File content: #{params[:form][:multiple_documents][0][:tempfile].read}"
      buffer.join(' | ')
    rescue
      'No files uploaded'
    end
  end
end

if __FILE__ == $0
  Rack::Handler::WEBrick.run TestApp, :Port => 8070
end
