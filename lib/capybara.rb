require 'timeout'
require 'nokogiri'

module Capybara
  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class ElementNotFound < CapybaraError; end
  class OptionNotFound < ElementNotFound; end
  class UnselectNotAllowed < CapybaraError; end
  class NotSupportedByDriverError < CapybaraError; end
  class TimeoutError < CapybaraError; end
  class LocateHiddenElementError < CapybaraError; end
  class InfiniteRedirectError < TimeoutError; end

  class << self
    attr_accessor :asset_root, :app_host, :run_server, :default_host
    attr_accessor :default_selector, :default_wait_time, :ignore_hidden_elements
    attr_accessor :save_and_open_page_path

    ##
    #
    # Configure Capybara to suit your needs.
    #
    #     Capybara.configure do |config|
    #       config.run_server = false
    #       config.app_host   = 'http://www.google.com'
    #     end
    #
    # === Configurable options
    #
    # [asset_root = String]               Where static assets are located, used by save_and_open_page
    # [app_host = String]                 The default host to use when giving a relative URL to visit
    # [run_server = Boolean]              Whether to start a Rack server for the given Rack app (Default: true)
    # [default_selector = :css/:xpath]    Methods which take a selector use the given type by default (Default: CSS)
    # [default_wait_time = Integer]       The number of seconds to wait for asynchronous processes to finish (Default: 2)
    # [ignore_hidden_elements = Boolean]  Whether to ignore hidden elements on the page (Default: false)
    #
    # === DSL Options
    #
    # when using capybara/dsl, the following options are also available:
    #
    # [default_driver = Symbol]           The name of the driver to use by default. (Default: :rack_test)
    # [javascript_driver = Symbol]        The name of a driver to use for JavaScript enabled tests. (Default: :selenium)
    #
    def configure
      yield self
    end
  end

  autoload :Server,     'capybara/server'
  autoload :Session,    'capybara/session'
  autoload :XPath,      'capybara/xpath'
  autoload :Node,       'capybara/node'
  autoload :Document,   'capybara/node'
  autoload :Element,    'capybara/node'
  autoload :VERSION,    'capybara/version'

  module Driver
    autoload :Base,     'capybara/driver/base'
    autoload :Node,     'capybara/driver/node'
    autoload :RackTest, 'capybara/driver/rack_test_driver'
    autoload :Celerity, 'capybara/driver/celerity_driver'
    autoload :Culerity, 'capybara/driver/culerity_driver'
    autoload :Selenium, 'capybara/driver/selenium_driver'
  end
end

Capybara.configure do |config|
  config.run_server = true
  config.default_selector = :css
  config.default_wait_time = 2
  config.ignore_hidden_elements = false
end
