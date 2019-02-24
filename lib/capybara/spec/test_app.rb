# frozen_string_literal: true

require 'sinatra/base'
require 'tilt/erb'
require 'rack'
require 'yaml'

class TestApp < Sinatra::Base
  class TestAppError < Exception; end # rubocop:disable Lint/InheritException
  class TestAppOtherError < Exception # rubocop:disable Lint/InheritException
    def initialize(string1, msg)
      @something = string1
      @message = msg
    end
  end
  set :root, File.dirname(__FILE__)
  set :static, true
  set :raise_errors, true
  set :show_exceptions, false

  @@form_post_count = 0
  # Also check lib/capybara/spec/views/*.erb for pages not listed here

  get '/' do
    response.set_cookie('capybara', value: 'root cookie', domain: request.host, path: request.path)
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

  post '/redirect_307' do
    redirect '/landed', 307
  end

  post '/redirect_308' do
    redirect '/landed', 308
  end

  get '/referer_base' do
    '<a href="/get_referer">direct link</a>' \
    '<a href="/redirect_to_get_referer">link via redirect</a>' \
    '<form action="/get_referer" method="get"><input type="submit"></form>'
  end

  get '/redirect_to_get_referer' do
    redirect '/get_referer'
  end

  get '/get_referer' do
    request.referer.nil? ? 'No referer' : "Got referer: #{request.referer}"
  end

  get '/host' do
    "Current host is #{request.scheme}://#{request.host}:#{request.port}"
  end

  get '/redirect/:times/times' do
    times = params[:times].to_i
    if times.zero?
      'redirection complete'
    else
      redirect "/redirect/#{times - 1}/times"
    end
  end

  get '/landed' do
    'You landed'
  end

  post '/landed' do
    "You post landed: #{params.dig(:form, 'data')}"
  end

  get '/with-quotes' do
    %q("No," he said, "you can't do that.")
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

  delete '/delete' do
    'The requested object was deleted'
  end

  get '/delete' do
    'Not deleted'
  end

  get '/redirect_back' do
    redirect back
  end

  get '/redirect_secure' do
    redirect "https://#{request.host}:#{request.port}/host"
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

  get '/error' do
    raise TestAppError, 'some error'
  end

  get '/other_error' do
    raise TestAppOtherError.new('something', 'other error')
  end

  get '/load_error' do
    raise LoadError
  end

  get '/with.*html' do
    erb :with_html, locals: { referrer: request.referrer }
  end

  get '/with_title' do
    <<-HTML
      <title>#{params[:title] || 'Test Title'}</title>
      <body>
        <svg><title>abcdefg</title></svg>
      </body>
    HTML
  end

  get '/download.csv' do
    content_type 'text/csv'
    'This, is, comma, separated' \
    'Thomas, Walpole, was , here'
  end

  get '/:view' do |view|
    erb view.to_sym, locals: { referrer: request.referrer }
  end

  post '/form' do
    @@form_post_count += 1
    '<pre id="results">' + params[:form].merge('post_count' => @@form_post_count).to_yaml + '</pre>'
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
      buffer << "Content-type: #{params.dig(:form, :document, :type)}"
      buffer << "File content: #{params.dig(:form, :document, :tempfile).read}"
      buffer.join(' | ')
    rescue StandardError
      'No file uploaded'
    end
  end

  post '/upload_multiple' do
    begin
      docs = params.dig(:form, :multiple_documents)
      buffer = [docs.size.to_s]
      docs.each do |doc|
        buffer << "Content-type: #{doc[:type]}"
        buffer << "File content: #{doc[:tempfile].read}"
      end
      buffer.join(' | ')
    rescue StandardError
      'No files uploaded'
    end
  end
end

Rack::Handler::Puma.run TestApp, Port: 8070 if $PROGRAM_NAME == __FILE__
