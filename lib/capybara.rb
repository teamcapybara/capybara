require 'timeout'
require 'nokogiri'

module Capybara
  VERSION = '0.2.0'

  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class ElementNotFound < CapybaraError; end
  class NotSupportedByDriverError < CapybaraError; end
  class TimeoutError < CapybaraError; end
  class LocateHiddenElementError < CapybaraError; end
  class InfiniteRedirectError < TimeoutError; end
  
  class << self
    attr_accessor :debug, :asset_root, :app_host
    attr_writer :default_selector, :default_wait_time
    attr_writer :ignore_hidden_elements

    def default_selector
      @default_selector ||= :xpath
    end
    
    def default_wait_time
      @default_wait_time ||= 2
    end

    def ignore_hidden_elements
      (@ignore_hidden_elements.nil? || @ignore_hidden_elements) ? true : false
    end

    def log(message)
      puts "[capybara] #{message}" if debug
      true
    end
  end
  
  autoload :Server,     'capybara/server'
  autoload :Session,    'capybara/session'
  autoload :Node,       'capybara/node'
  autoload :XPath,      'capybara/xpath'
  autoload :Searchable, 'capybara/searchable'
  
  module Driver
    autoload :Base,     'capybara/driver/base'
    autoload :RackTest, 'capybara/driver/rack_test_driver'
    autoload :Celerity, 'capybara/driver/celerity_driver'
    autoload :Culerity, 'capybara/driver/culerity_driver'
    autoload :Selenium, 'capybara/driver/selenium_driver'
  end
end
