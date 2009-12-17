


class Capybara::Driver::Celerity < Capybara::Driver::Base
  class Node < Capybara::Node
    def text
      node.text
    end

    def [](name)
      value = if name.to_sym == :class
        node.class_name
      else
        node.send(name.to_sym)
      end
      return value if value and not value.empty?
    end

    def set(value)
      node.set(value)
    end

    def select(option)
      node.select(option)
    end

    def click
      node.click
    end

    def drag_to(element)
      node.fire_event('mousedown')
      element.node.fire_event('mousemove')
      element.node.fire_event('mouseup')
    end

    def tag_name
      # FIXME: this might be the dumbest way ever of getting the tag name
      # there has to be something better...
      node.to_xml[/^\s*<([a-z0-9\-\:]+)/, 1]
    end
  end

  attr_reader :app, :rack_server, :host, :port, :celerity_options, :culerity
  
  def self.server
    unless @_server
      @_server = ::Culerity::run_server
      at_exit do
        @_server.close
      end
    end
    @_server
  end
  
  def initialize(app, options = {})
   
    @app = app
    
    top_opts = [:driver, :host, :port, :rack, :culerity]
    
    if options[:rack] == false
      @host = options[:host] || 'localhost'
      @port = options[:port] || '3001'
      Capybara.log("celerity driver using #{host}:#{port}")
    else
      @rack_server = Capybara::Server.new(@app)
      Capybara.log("celerity driver using rack")
    end
    
    @celerity_options = {
      :browser   => :firefox, 
      :log_level => :off
    }.merge(options.reject {|k,v| top_opts.include?(k) })
     
    @culerity = options[:culerity] || !RUBY_PLATFORM.match(/java/) 
     
  end
   
  def visit(path)
    browser.goto(url(path))
  end
  
  def response
    Rack::MockResponse.new(browser.status_code, browser.response_headers, browser.html)
  end

  def find(selector)
    browser.elements_by_xpath(selector).map { |node| Node.new(self, node) }
  end
  
  def wait?; true; end

  def evaluate_script(script)
    browser.execute_script "#{script}"
  end

 
    
private

  def url(path)
    if rack_server
      rack_server.url(path)
    else
      "http://#{host}:#{port}#{path}"
    end
  end

  def browser
    unless @_browser
      if culerity
        Capybara.log "celerity driver via Culerity" 
        require 'culerity'
        @_browser = ::Culerity::RemoteBrowserProxy.new self.class.server, celerity_options
        at_exit do
          @_browser.exit
        end
      else 
        require 'celerity'
        @_browser = ::Celerity::Browser.new(celerity_options)         
      end
    end
    
    @_browser
    
  end

end
