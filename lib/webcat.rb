module Webcat
  VERSION = '0.1'

  class WebcatError < StandardError; end
  class DriverNotFoundError < WebcatError; end

  class << self
    attr_accessor :debug
    
    def log(message)
      puts message if debug
    end
  end
  
  autoload :Server, 'webcat/server'
  autoload :Session, 'webcat/session'

  module Driver
    autoload :RackTest, 'webcat/rack_test_driver'
    autoload :Culerity, 'webcat/culerity_driver'
    autoload :SafariWatir, 'webcat/safariwatir_driver'
    autoload :FireWatir, 'webcat/firewatir_driver'
  end
end