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

  def visit(path, attributes = {})
    reset_host!
    process(:get, path, attributes)
    follow_redirects!
  end

  def submit(method, path, attributes)
    path = request_path if not path or path.empty?
    process(method, path, attributes)
    follow_redirects!
  end

  def follow(method, path, attributes = {})
    return if path.gsub(/^#{request_path}/, '').start_with?('#')
    process(method, path, attributes)
    follow_redirects!
  end

  def follow_redirects!
    5.times do
      process(:get, last_response["Location"]) if last_response.redirect?
    end
    raise Capybara::InfiniteRedirectError, "redirected more than 5 times, check for infinite redirects." if last_response.redirect?
  end

  def process(method, path, attributes = {})
    new_uri = URI.parse(path)
    current_uri = URI.parse(current_url)

    if new_uri.host
      @current_host = new_uri.scheme + '://' + new_uri.host
    end

    if new_uri.relative?
      if path.start_with?('?')
        path = request_path + path
      elsif not path.start_with?('/')
        path = request_path.sub(%r(/[^/]*$), '/') + path
      end
      path = current_host + path
    end

    reset_cache!
    send(method, path, attributes, env)
  end

  def current_url
    last_request.url
  rescue Rack::Test::Error
    ""
  end

  def reset_host!
    @current_host = (Capybara.app_host || Capybara.default_host)
  end

  def reset_cache!
    @dom = nil
  end

  def body
    dom.to_xml
  end

  def dom
    @dom ||= Nokogiri::HTML(source)
  end

  def find(selector)
    dom.xpath(selector).map { |node| Capybara::RackTest::Node.new(self, node) }
  end

  def source
    last_response.body
  rescue Rack::Test::Error
    nil
  end

protected

  def build_rack_mock_session
    reset_host! unless current_host
    Rack::MockSession.new(app, URI.parse(current_host).host)
  end

  def request_path
    last_request.path
  rescue Rack::Test::Error
    ""
  end

  def env
    env = {}
    begin
      env["HTTP_REFERER"] = last_request.url
    rescue Rack::Test::Error
      # no request yet
    end
    env.merge!(options[:headers]) if options[:headers]
    env
  end

end
