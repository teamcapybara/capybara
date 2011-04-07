class Capybara::RackTest::Browser
  include ::Rack::Test::Methods

  attr_reader :app
  attr_accessor :current_host

  def initialize(app)
    @app = app
  end

  def visit(path, attributes = {})
    reset_host!
    process(:get, path, attributes)
  end

  def submit(method, path, attributes)
    path = request_path if not path or path.empty?
    process(method, path, attributes)
  end

  def follow(method, path, attributes = {})
    return if path.gsub(/^#{request_path}/, '').start_with?('#')
    process(method, path, attributes)
  end

  def follow_redirects!
    5.times do
      follow_redirect! if last_response.redirect?
    end
    raise Capybara::InfiniteRedirectError, "redirected more than 5 times, check for infinite redirects." if last_response.redirect?
  end

  def process(method, path, attributes = {})
    new_uri = URI.parse(path)
    current_uri = URI.parse(current_url)

    path = request_path + path if path.start_with?('?')
    path = current_host + path if path.start_with?('/')

    if new_uri.host
      @current_host = new_uri.scheme + '://' + new_uri.host
    end

    reset_cache!
    send(method, to_binary(path), to_binary( attributes ), env)
    follow_redirects!
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

  def to_binary(object)
    return object unless Kernel.const_defined?(:Encoding)

    if object.respond_to?(:force_encoding)
      object.dup.force_encoding(Encoding::ASCII_8BIT)
    elsif object.respond_to?(:each_pair) #Hash
      {}.tap { |x| object.each_pair {|k,v| x[to_binary(k)] = to_binary(v) } }
    elsif object.respond_to?(:each) #Array
      object.map{|x| to_binary(x)}
    else
      object
    end
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
    env
  end

end
