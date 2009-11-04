require 'culerity'
require 'rack'
require 'net/http'

class Webcat::Driver::Culerity
  Response = Struct.new(:body)
  
  attr_reader :app, :rack_server

  def initialize(app)
    @app = app
    @rack_server = Webcat::Server.new(@app)
    @rack_server.boot
  end
  
  def get(path)
    browser.goto(url(path))
  end
  
  def body
    browser.text
  end

private

  def url(path)
    rack_server.url(path)
  end

  def server
    unless @_server
      @_server = ::Culerity::run_server
      at_exit do
        @_server.close
      end
    end
    @_server
  end
  
  def browser
    unless @_browser
      @_browser = ::Culerity::RemoteBrowserProxy.new server, {:browser => :firefox, :log_level => :off}
      at_exit do
        @_browser.exit
      end
    end
    @_browser
  end

end