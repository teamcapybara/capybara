require 'rack/test'
require 'rack/utils'
require 'mime/types'
require 'nokogiri'
require 'cgi'

class Capybara::RackTest::Driver < Capybara::Driver::Base
  attr_reader :app, :options

  def initialize(app, options={})
    raise ArgumentError, "rack-test requires a rack application, but none was given" unless app
    @app = app
    @options = options
  end

  def browser
    @browser ||= Capybara::RackTest::Browser.new(app, options)
  end

  def response
    browser.last_response
  end

  def request
    browser.last_request
  end

  def visit(path, attributes = {})
    browser.visit(path, attributes)
  end

  def submit(method, path, attributes)
    browser.submit(method, path, attributes)
  end

  def follow(method, path, attributes = {})
    browser.follow(method, path, attributes)
  end

  def current_url
    browser.current_url
  end

  def cookies
    cookies = []
    browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar.instance_variable_get(:@cookies).each do |rack_cookie|
      cookie = {}
      cookie[:name] = rack_cookie.instance_variable_get(:@name)
      cookie[:value] = rack_cookie.instance_variable_get(:@value)
      cookie[:path] = rack_cookie.instance_variable_get(:@options)["path"]
      cookie[:domain] = rack_cookie.instance_variable_get(:@options)["domain"]
      cookie[:expires] = rack_cookie.instance_variable_get(:@options)["expires"]
      cookies.push cookie
    end
    cookies
  end

  def cookie_named(name)
    cookies.find { |c| c[:name] == name }
  end

  def response_headers
    response.headers
  end

  def status_code
    response.status
  end

  def find(selector)
    browser.find(selector)
  end

  def body
    browser.body
  end

  def source
    browser.source
  end

  def dom
    browser.dom
  end

  def reset!
    @browser = nil
  end

  def get(*args, &block); browser.get(*args, &block); end
  def post(*args, &block); browser.post(*args, &block); end
  def put(*args, &block); browser.put(*args, &block); end
  def delete(*args, &block); browser.delete(*args, &block); end
  def header(key, value); browser.header(key, value); end
end
