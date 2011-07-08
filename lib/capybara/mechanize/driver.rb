require 'rack/test'
require 'rack/utils'
require 'mechanize'

class Capybara::Mechanize::Driver < Capybara::Driver::Base
  attr_reader :app, :rack_server, :options

  def initialize(app, options={})
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
    # Don't go anywhere if the path ends with a hash (i.e. JS links).
    return if path.gsub(/^#{request_path}/, '').start_with?('#')
    
    absolute_url = if URI.parse(path).relative?
                     # If we have no path append the current path.
                     path = "/#{ request_path }#{ path }" if path.start_with?('?')
                     
                     if current_page? && (current_page.uri.host != (Capybara.app_host || rack_server.host))
                       new_uri      = current_page.uri.clone
                       new_uri.path = path
                       
                       new_uri.to_s
                     else
                       url(path)
                     end
                   else
                     path
                   end
                    
    # Make sure that we append the current page as the referer for 
    # GET requests.
    if _method == :get
      browser.get(absolute_url, [], self.current_url)
    else
      browser.send(_method, absolute_url, attributes)      
    end
  end
  
  def submit(form_node, button_node)
    # Remove diabled nodes as this is what we expect but its not what
    # mechanize does.
    form_node.search('*[disabled=disabled]').remove
    
    form   = Mechanize::Form.new(form_node, browser)
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
  
  def request_path
    browser.current_page.uri.path
  end
  
end
