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
    
    def visible?
      node.visible?
    end
    
    def path
      node.xpath
    end
    
  end

  attr_reader :app, :rack_server
  
  def initialize(app)
    @app = app
    unless Capybara.app_host
      @rack_server = Capybara::Server.new(@app)
    end
  end
   
  def visit(path)
    browser.goto(url(path))
  end
  
  def current_url
    browser.url
  end
  
  def body
    browser.html
  end
  
  def response_headers
    browser.response_headers
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
      Capybara.app_host.to_s + path
    end
  end

  def browser
    unless @_browser
      require 'celerity'
      @_browser = ::Celerity::Browser.new(:browser => :firefox, :log_level => :off)
    end
    
    @_browser
  end

end
