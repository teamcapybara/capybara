require 'watir'
Watir::Browser.default = "firefox"

class Webcat::Driver::FireWatir
  class Node < Struct.new(:node)
    def text
      node.text
    end
    
    def attribute(name)
      value = if name.to_sym == :class
        node.class_name
      else
        node.send(name.to_sym)
      end
      return value if value and not value.empty?
    end
    
    def click
      node.click
    end
    
    def tag_name
      # FIXME: this might be the dumbest way ever of getting the tag name
      # there has to be something better...
      node.to_xml[/^\s*<([a-z0-9\-\:]+)/, 1]
    end
  end
  
  attr_reader :app, :rack_server

  def initialize(app)
    @app = app
    @rack_server = Webcat::Server.new(@app)
    @rack_server.boot
  end
  
  def visit(path)
    browser.goto(url(path))
  end
  
  def body
    browser.html
  end
  
  def find(selector)
    browser.elements_by_xpath(selector).map { |node| Node.new(node) }
  end

private

  def url(path)
    rack_server.url(path)
  end
  
  def browser
    unless @_browser
      @_browser = Watir::Browser.new
      at_exit do
        @_browser.exit
      end
    end
    @_browser
  end

end