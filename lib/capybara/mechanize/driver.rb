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
    @browser = Mechanize.new do |config|
      config.follow_meta_refresh = true
      config.redirection_limit   = 5
    end unless @browser

    @browser
  end

  def visit(path)
    browser.get(url(path))
  end

  def follow(_method, path)
    return if is_fragment?(path)
    
    absolute_url = make_absolute_url(path)
    
    if _method == :get
      browser.get(absolute_url, [], self.current_url)
    else
      browser.send(_method, absolute_url)
    end
  end

  def submit(form)
    browser.submit(form)
  end

  def current_url
    has_current_page? ? current_page.uri.to_s : ''
  end

  def response_headers
    has_current_page? ? current_page.header : {}
  end

  def status_code
    has_current_page? ? current_page.code.to_i : nil
  end

  def find(selector)
    dom.search(selector).map { |node| Capybara::Mechanize::Node.new(self, node) }
  end

  def source
    has_current_page? ? current_page.body : ''
  end
  alias :body :source

  def dom
    has_current_page? ? current_page.root : Nokogiri::HTML(nil)
  end

  def reset!
    @browser = nil
  end

  private
  
  def make_absolute_url(path)
    return path unless URI.parse(path).relative?

    path = "#{ current_page.uri.path }#{ path }" if is_query_string?(path)

    if has_current_page? && current_page_is_external?
      external_url(path)
    else
      url(path)
    end
  end
  
  def external_url(path)
    current_page.uri.merge(path).to_s  
  end
  
  def url(path)
    rack_server.url(path)
  end

  def current_page
    browser.current_page
  end

  def has_current_page?
    !browser.current_page.nil?
  end

  def current_page_is_external?
    if Capybara.app_host.nil?
      current_page.uri.host != rack_server.host 
    else
      current_page.uri.host != (rack_server.host || URI.parse(Capybara.app_host).host)
    end
  end
  
  def is_query_string?(path)
    path.start_with?('?')
  end

  def is_fragment?(path)
    has_current_page? && path.gsub(/^#{current_page.uri.path}/, '').start_with?('#')
  end
end
