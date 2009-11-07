require 'selenium/client'
require 'webcat/driver/selenium/rc_server'
require 'webcat/core_ext/tcp_socket'


class Webcat::Driver::Selenium
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

  def self.server
    @server ||= Webcat::Selenium::SeleniumRCServer.new
  end

  def initialize(app)
    @app = app
    @rack_server = Webcat::Server.new(@app)
    @rack_server.boot
    self.class.server.boot
  end
  
  def visit(path)
    browser.open(url(path))
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
      @_browser = Selenium::Client::Driver.new :host => 'localhost',
            :port => 4444, 
            :browser => "*firefox", 
            :url => rack_server.url('/'), 
            :timeout_in_second => 10
      @_browser.start_new_browser_session
      
      at_exit do
        @_browser.close_current_browser_session
      end
    end
    @_browser
  end

end

