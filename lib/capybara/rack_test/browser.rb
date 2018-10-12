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
    return if fragment_or_script?(path)

    process_and_follow_redirects(method, path, attributes, 'HTTP_REFERER' => current_url)
  end

  def process_and_follow_redirects(method, path, attributes = {}, env = {})
    process(method, path, attributes, env)

    return unless driver.follow_redirects?

    driver.redirect_limit.times do
      if last_response.redirect?
        if [307, 308].include? last_response.status
          process(last_request.request_method, last_response['Location'], last_request.params, env)
        else
          process(:get, last_response['Location'], {}, env)
        end
      end
    end
    raise Capybara::InfiniteRedirectError, "redirected more than #{driver.redirect_limit} times, check for infinite redirects." if last_response.redirect?
  end

  def process(method, path, attributes = {}, env = {})
    method = method.downcase
    new_uri = build_uri(path)
    @current_scheme, @current_host, @current_port = new_uri.select(:scheme, :host, :port)

    reset_cache!
    send(method, new_uri.to_s, attributes, env.merge(options[:headers] || {}))
  end

  def build_uri(path)
    URI.parse(path).tap do |uri|
      uri.path = request_path if path.empty? || path.start_with?('?')
      uri.path = '/' if uri.path.empty?
      uri.path = request_path.sub(%r{/[^/]*$}, '/') + uri.path unless uri.path.start_with?('/')

      uri.scheme ||= @current_scheme
      uri.host ||= @current_host
      uri.port ||= @current_port unless uri.default_port == @current_port
    end
  end

  def current_url
    last_request.url
  rescue Rack::Test::Error
    ''
  end

  def reset_host!
    uri = URI.parse(driver.session_options.app_host || driver.session_options.default_host)
    @current_scheme, @current_host, @current_port = uri.select(:scheme, :host, :port)
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
    ''
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
    '/'
  end

private

  def fragment_or_script?(path)
    path.gsub(/^#{Regexp.escape(request_path)}/, '').start_with?('#') || path.downcase.start_with?('javascript:')
  end
end
