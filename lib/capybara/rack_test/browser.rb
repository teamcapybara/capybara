# frozen_string_literal: true

class Capybara::RackTest::Browser
  include ::Rack::Test::Methods

  attr_reader :driver
  attr_accessor :current_host

  def initialize(driver)
    @driver = driver
  end

  def app
    driver.app
  end

  def options
    driver.options
  end

  def visit(path, **attributes)
    reset_host!
    process_and_follow_redirects(:get, path, attributes)
  end

  def refresh
    reset_cache!
    request(last_request.fullpath, last_request.env)
  end

  def submit(method, path, attributes)
    path = request_path if path.nil? || path.empty?
    process_and_follow_redirects(method, path, attributes, 'HTTP_REFERER' => current_url)
  end

  def follow(method, path, **attributes)
    return if path.gsub(/^#{Regexp.escape(request_path)}/, '').start_with?('#') || path.downcase.start_with?('javascript:')
    process_and_follow_redirects(method, path, attributes, 'HTTP_REFERER' => current_url)
  end

  def process_and_follow_redirects(method, path, attributes = {}, env = {})
    process(method, path, attributes, env)

    return unless driver.follow_redirects?

    driver.redirect_limit.times do
      process(:get, last_response["Location"], {}, env) if last_response.redirect?
    end
    raise Capybara::InfiniteRedirectError, "redirected more than #{driver.redirect_limit} times, check for infinite redirects." if last_response.redirect?
  end

  def process(method, path, attributes = {}, env = {})
    new_uri = URI.parse(path)
    method.downcase! unless method.is_a? Symbol
    if path.empty?
      new_uri.path = request_path
    else
      new_uri.path = request_path if path.start_with?("?")
      new_uri.path = "/" if new_uri.path.empty?
      new_uri.path = request_path.sub(%r{/[^/]*$}, '/') + new_uri.path unless new_uri.path.start_with?('/')
    end
    new_uri.scheme ||= @current_scheme
    new_uri.host ||= @current_host
    new_uri.port ||= @current_port unless new_uri.default_port == @current_port

    @current_scheme = new_uri.scheme
    @current_host = new_uri.host
    @current_port = new_uri.port

    reset_cache!
    send(method, new_uri.to_s, attributes, env.merge(options[:headers] || {}))
  end

  def current_url
    last_request.url
  rescue Rack::Test::Error
    ""
  end

  def reset_host!
    uri = URI.parse(driver.session_options.app_host || driver.session_options.default_host)
    @current_scheme = uri.scheme
    @current_host = uri.host
    @current_port = uri.port
  end

  def reset_cache!
    @dom = nil
  end

  def dom
    @dom ||= Capybara::HTML(html)
  end

  def find(format, selector)
    if format == :css
      dom.css(selector, Capybara::RackTest::CSSHandlers.new)
    else
      dom.xpath(selector)
    end.map { |node| Capybara::RackTest::Node.new(self, node) }
  end

  def html
    last_response.body
  rescue Rack::Test::Error
    ""
  end

  def title
    dom.title
  end

protected

  def build_rack_mock_session
    reset_host! unless current_host
    Rack::MockSession.new(app, current_host)
  end

  def request_path
    last_request.path
  rescue Rack::Test::Error
    "/"
  end
end
