module Webcat
  class << self
    attr_accessor :debug
    
    def log(message)
      puts message if debug
    end
  end
  
  class Session
    attr_reader :mode, :app

    def initialize(mode, app)
      @mode = mode
      @app = app
    end

    def driver
      @driver ||= Webcat::Driver::RackTest.new(app) 
    end

    def get(path)
      driver.get(path)
    end

    def body
      driver.response.body
    end
  end
  
  autoload :Server, 'webcat/server'

  module Driver
    autoload :RackTest, 'webcat/rack_test_driver'
    autoload :Culerity, 'webcat/culerity_driver'
  end
end