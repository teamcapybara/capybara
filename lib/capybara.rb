require 'nokogiri'

module Capybara
  VERSION = '0.1.3'

  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class ElementNotFound < CapybaraError; end

  class << self
    attr_accessor :debug, :asset_root
    
    def log(message)
      puts "[capybara] #{message}" if debug
      true
    end
  end
  
  autoload :Server, 'capybara/server'
  autoload :Session, 'capybara/session'
  autoload :Node, 'capybara/node'

  module Driver
    autoload :RackTest, 'capybara/driver/rack_test_driver'
    autoload :Culerity, 'capybara/driver/culerity_driver'
    autoload :SafariWatir, 'capybara/driver/safariwatir_driver'
    autoload :FireWatir, 'capybara/driver/firewatir_driver'
    autoload :Selenium, 'capybara/driver/selenium_driver'
  end
end
