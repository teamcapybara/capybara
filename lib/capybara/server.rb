require 'uri'
require 'net/http'
require 'rack'
require 'rack/handler/mongrel'

class Capybara::Server
  attr_reader :app
  
  def initialize(app)
    @app = app
  end
  
  def port
    8080
  end

  def host
    'localhost'
  end

  def url(path)
    path = URI.parse(path).request_uri if path =~ /^http/
    "http://#{host}:#{port}#{path}"
  end
  
  def boot
    Capybara.log "application has already booted" and return if responsive?
    Capybara.log "booting Rack applicartion on port #{port}"
    start_time = Time.now
    Thread.new do
      Rack::Handler::Mongrel.run @app, :Port => port
    end
    Capybara.log "checking if application has booted"
    loop do
      Capybara.log("application has booted") and break if responsive?
      if Time.now - start_time > 10 
        Capybara.log "Rack application timed out during boot"
        exit
      end
      
      Capybara.log '.'
      sleep 1
    end
  end

  def responsive?
    res = Net::HTTP.start(host, port) { |http| http.get('/') }

    if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
      return true
    end
  rescue Errno::ECONNREFUSED 
    return false
  end

end
