require 'culerity'
require 'rack'
require 'net/http'

class Webcat::Driver::Culerity
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
  end
  
  attr_reader :app, :rack_server

  def self.server
    unless @_server
      @_server = ::Culerity::run_server
      at_exit do
        @_server.close
      end
    end
    @_server
  end

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
      @_browser = ::Culerity::RemoteBrowserProxy.new self.class.server, {:browser => :firefox, :log_level => :off}
      at_exit do
        @_browser.exit
      end
    end
    @_browser
  end

end