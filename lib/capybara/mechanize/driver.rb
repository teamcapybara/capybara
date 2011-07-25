require 'mechanize'

class Capybara::Mechanize::Driver < Capybara::Driver::Base
  attr_reader :app, :rack_server, :options

  def initialize(app, options={})
    raise ArgumentError, "Mechanize requires a rack application, but none was given" unless app
    
    @app         = app
    @options     = options
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def browser
    unless @browser
      @browser = Mechanize.new
      @browser.follow_meta_refresh
    end
    @browser
  end

  def visit(path)
    browser.get(url(path))
  end

  def follow(_method, path, attributes={})
    return if is_javascript_hashy_path?(path)

    absolute_url = make_absolute_url(path)

    if _method == :get
      browser.get(absolute_url, [], self.current_url)
    else
      browser.send(_method, absolute_url, attributes)
    end
  end

  def submit(form_node, button_node)
    form   = Capybara::Mechanize::Form.new(form_node, browser)
    button = Mechanize::Form::Button.new(button_node)

    form.action = form.action || self.current_url

    browser.submit(form, button)
  end

  def current_url
    current_page? ? current_page.uri.to_s : ''
  end

  def response_headers
    current_page? ? current_page.header : {}
  end

  def status_code
    current_page? ? current_page.code.to_i : nil
  end

  def find(selector)
    dom.search(selector).map { |node| Capybara::Mechanize::Node.new(self, node) }
  end

  def source
    current_page? ? current_page.body : ''
  end
  alias :body :source

  def dom
    current_page? ? current_page.root : Nokogiri::HTML(nil)
  end

  def reset!
    @browser = nil
  end

  private

  def url(path)
    rack_server.url(path)
  end

  def current_page
    browser.current_page
  end

  def current_page?
    !browser.current_page.nil?
  end

  def current_page_is_external?
    current_page.uri.host != (Capybara.app_host || rack_server.host)
  end

  def request_path
    browser.current_page.uri.path
  end

  def make_absolute_url(path)
    return path unless URI.parse(path).relative?

    path = "#{ request_path }#{ path }" if is_query_string?(path)

    if current_page? && current_page_is_external?
      current_page.uri.merge(path).to_s
    else
      url(path)
    end
  end
  
  def is_query_string?(path)
    path.start_with?('?')
  end

  def is_javascript_hashy_path?(path)
    path.gsub(/^#{request_path}/, '').start_with?('#')
  end
end
