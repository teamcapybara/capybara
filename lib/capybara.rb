require 'nokogiri'

module Capybara
  VERSION = '0.1.4'

  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class ElementNotFound < CapybaraError; end
  class NotSupportedByDriverError < CapybaraError; end

  class << self
    attr_accessor :debug, :asset_root
    attr_writer :default_selector

    def default_selector
      @default_selector ||= :xpath
    end

    def log(message)
      puts "[capybara] #{message}" if debug
      true
    end
  end
  
  autoload :Server,  'capybara/server'
  autoload :Session, 'capybara/session'
  autoload :Node,    'capybara/node'
  autoload :XPath,   'capybara/xpath'

  module Driver
    autoload :Base,     'capybara/driver/base'
    autoload :RackTest, 'capybara/driver/rack_test_driver'
    autoload :Culerity, 'capybara/driver/culerity_driver'
    autoload :Selenium, 'capybara/driver/selenium_driver'
  end
end
