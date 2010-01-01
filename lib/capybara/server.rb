require 'uri'
require 'net/http'
require 'rack'
begin
  require 'rack/handler/mongrel'
rescue LoadError
  require 'rack/handler/webrick'
end

class Capybara::Server
  class Identify
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] == "/__identify__"
        [200, {}, @app.object_id.to_s]
      else
        @app.call(env)
      end
    end
  end

  attr_reader :app, :port

  def initialize(app)
    @app = app
    find_available_port
    boot
  end

  def host
    'localhost'
  end

  def url(path)
    path = URI.parse(path).request_uri if path =~ /^http/
    "http://#{host}:#{port}#{path}"
  end

  def responsive?
    is_running_on_port?(port)
  end

private

  def boot
    Capybara.log "application has already booted" and return if responsive?
    Capybara.log "booting Rack applicartion on port #{port}"

    Timeout.timeout(10) do
      Thread.new do
        if defined?(Rack::Handler::Mongrel)
          Rack::Handler::Mongrel.run(Identify.new(@app), :Port => port)
        else
          Rack::Handler::WEBrick.run(Identify.new(@app), :Port => port, :AccessLog => [])
        end
      end
      Capybara.log "checking if application has booted"

      loop do
        Capybara.log("application has booted") and break if responsive?
        sleep 0.5
      end
    end
  rescue Timeout::Error
    Capybara.log "Rack application timed out during boot"
    exit
  end

  def find_available_port
    @port = 9887
    @port += 1 while is_port_open?(@port) and not is_running_on_port?(@port)
  end

  def is_running_on_port?(tested_port)
    res = Net::HTTP.start(host, tested_port) { |http| http.get('/__identify__') }

    if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
      return res.body == @app.object_id.to_s
    end
  rescue Errno::ECONNREFUSED
    return false
  end

  def is_port_open?(tested_port)
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(host, tested_port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
    return false
  end

end
