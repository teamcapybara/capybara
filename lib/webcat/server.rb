require 'net/http'

class Webcat::Server
  attr_reader :app
  
  def initialize(app)
    @app = app
  end
  
  def port
    9081
  end

  def host
    'localhost'
  end

  def url(path)
    "http://#{host}:#{port}#{path}"
  end
  
  def boot
    Webcat.log "[webcat] Booting Rack applicartion on port #{port}"
    start_time = Time.now
    Thread.new do
      Rack::Handler::Mongrel.run @app, :Port => port
    end
    Webcat.log "[webcat] checking if application has booted"
    loop do
      begin
        res = Net::HTTP.start(host, port) { |http| http.get('/') }

        if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
          Webcat.log "[webcat] application has booted"
          break
        end
      rescue Errno::ECONNREFUSED
      end

      if Time.now - start_time > 5
        puts "[webcat] Rack application timed out during boot"
        exit
      end
      
      Webcat.log '.'
      sleep 1
    end
  end
  
end