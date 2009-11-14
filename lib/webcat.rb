module Webcat
  VERSION = '0.1'

  class WebcatError < StandardError; end
  class DriverNotFoundError < WebcatError; end
  class ElementNotFound < WebcatError; end

  class << self
    attr_accessor :debug, :asset_root
    
    def log(message)
      puts "[webcat] #{message}" if debug
      true
    end
  end
  
  autoload :Server, 'webcat/server'
  autoload :Session, 'webcat/session'

  module Driver
    autoload :RackTest, 'webcat/driver/rack_test_driver'
    autoload :Culerity, 'webcat/driver/culerity_driver'
    autoload :SafariWatir, 'webcat/driver/safariwatir_driver'
    autoload :FireWatir, 'webcat/driver/firewatir_driver'
    autoload :Selenium, 'webcat/driver/selenium_driver'
  end
end
