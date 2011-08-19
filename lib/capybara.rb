require 'timeout'
require 'nokogiri'
require 'xpath'
module Capybara
  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class FrozenInTime < CapybaraError; end
  class ElementNotFound < CapybaraError; end
  class ExpectationNotMet < ElementNotFound; end
  class FileNotFound < CapybaraError; end
  class UnselectNotAllowed < CapybaraError; end
  class NotSupportedByDriverError < CapybaraError; end
  class TimeoutError < CapybaraError; end
  class LocateHiddenElementError < CapybaraError; end
  class InfiniteRedirectError < TimeoutError; end

  class << self
    attr_accessor :asset_root, :app_host, :run_server, :default_host
    attr_accessor :server_port, :server_boot_timeout
    attr_accessor :default_selector, :default_wait_time, :ignore_hidden_elements, :prefer_visible_elements
    attr_accessor :save_and_open_page_path, :automatic_reload

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
    # [prefer_visible_elements = Boolean] Whether to prefer visible elements over hidden elements (Default: true)
    # [automatic_reload = Boolean]        Whether to automatically reload elements as Capybara is waiting (Default: true)
    # [save_and_open_page_path = String]  Where to put pages saved through save_and_open_page (Default: Dir.pwd)
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

    ##
    #
    # Register a new driver for Capybara.
    #
    #     Capybara.register_driver :rack_test do |app|
    #       Capybara::Driver::RackTest.new(app)
    #     end
    #
    # @param [Symbol] name                    The name of the new driver
    # @yield [app]                            This block takes a rack app and returns a Capybara driver
    # @yieldparam [<Rack>] app                The rack application that this driver runs agains. May be nil.
    # @yieldreturn [Capybara::Driver::Base]   A Capybara driver instance
    #
    def register_driver(name, &block)
      drivers[name] = block
    end

    ##
    #
    # Add a new selector to Capybara. Selectors can be used by various methods in Capybara
    # to find certain elements on the page in a more convenient way. For example adding a
    # selector to find certain table rows might look like this:
    #
    #     Capybara.add_selector(:row) do
    #       xpath { |num| ".//tbody/tr[#{num}]" }
    #     end
    #
    # This makes it possible to use this selector in a variety of ways:
    #
    #     find(:row, 3)
    #     page.find('table#myTable').find(:row, 3).text
    #     page.find('table#myTable').has_selector?(:row, 3)
    #     within(:row, 3) { page.should have_content('$100.000') }
    #
    # It might be convenient to specify that the selector is automatically chosen for certain
    # values. This way you don't have to explicitly specify that you are looking for a row, or
    # an id. Let's say we want Capybara to treat any Symbols sent into methods like find to be
    # treated as though they were element ids. We could achieve this like so:
    #
    #     Capybara.add_selector(:id) do
    #       xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
    #       match { |value| value.is_a?(Symbol) }
    #     end
    #
    # Now we can retrieve elements by id like this:
    #
    #     find(:post_123)
    #
    # Note that this particular selector already ships with Capybara.
    #
    # @param [Symbol] name    The name of the selector to add
    # @yield                  A block executed in the context of the new {Capybara::Selector}
    #
    def add_selector(name, &block)
      Capybara::Selector.add(name, &block)
    end

    def drivers
      @drivers ||= {}
    end

    ##
    #
    # Register a proc that Capybara will call to run the Rack application.
    #
    #     Capybara.server do |app, port|
    #       require 'rack/handler/mongrel'
    #       Rack::Handler::Mongrel.run(app, :Port => port)
    #     end
    #
    # By default, Capybara will try to run thin, falling back to webrick.
    #
    # @yield [app, port]                      This block recieves a rack app and port and should run a Rack handler
    #
    def server(&block)
      if block_given?
        @server = block
      else
        @server
      end
    end

    ##
    #
    # Wraps the given string, which should contain an HTML document or fragment
    # in a {Capybara::Node::Simple} which exposes all {Capybara::Node::Matchers} and
    # {Capybara::Node::Finders}. This allows you to query any string containing
    # HTML in the exact same way you would query the current document in a Capybara
    # session. For example:
    #
    #     node = Capybara.string <<-HTML
    #       <ul>
    #         <li id="home">Home</li>
    #         <li id="projects">Projects</li>
    #       </ul>
    #     HTML
    #
    #     node.find('#projects').text # => 'Projects'
    #     node.has_selector?('li#home', :text => 'Home')
    #     node.has_selector?(:projects)
    #     node.find('ul').find('li').text # => 'Home'
    #
    # @param [String] html              An html fragment or document
    # @return [Capybara::Node::Simple]   A node which has Capybara's finders and matchers
    #
    def string(html)
      Capybara::Node::Simple.new(html)
    end

    ##
    #
    # Runs Capybara's default server for the given application and port
    # under most circumstances you should not have to call this method
    # manually.
    #
    # @param [Rack Application] app    The rack application to run
    # @param [Fixnum] port              The port to run the application on
    #
    def run_default_server(app, port)
      begin
        require 'rack/handler/thin'
        Thin::Logging.silent = true
        Rack::Handler::Thin.run(app, :Port => port)
      rescue LoadError
        require 'rack/handler/webrick'
        Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
      end
    end

    def deprecate(method, alternate_method)
      warn "DEPRECATED: ##{method} is deprecated, please use ##{alternate_method} instead"
    end
  end

  autoload :Server,     'capybara/server'
  autoload :Session,    'capybara/session'
  autoload :Selector,   'capybara/selector'
  autoload :VERSION,    'capybara/version'

  module Node
    autoload :Base,       'capybara/node/base'
    autoload :Simple,     'capybara/node/simple'
    autoload :Element,    'capybara/node/element'
    autoload :Document,   'capybara/node/document'
    autoload :Finders,    'capybara/node/finders'
    autoload :Matchers,   'capybara/node/matchers'
    autoload :Actions,    'capybara/node/actions'
  end

  module Driver
    autoload :Base,     'capybara/driver/base'
    autoload :Node,     'capybara/driver/node'

    class Selenium
      def initialize(*args)
        raise "Capybara::Driver::Selenium has been renamed to Capybara::Selenium::Driver"
      end
    end

    class RackTest
      def initialize(*args)
        raise "Capybara::Driver::RackTest has been renamed to Capybara::RackTest::Driver"
      end
    end
  end

  module RackTest
    autoload :Driver,  'capybara/rack_test/driver'
    autoload :Node,    'capybara/rack_test/node'
    autoload :Form,    'capybara/rack_test/form'
    autoload :Browser, 'capybara/rack_test/browser'
  end

  module Selenium
    autoload :Node,    'capybara/selenium/node'
    autoload :Driver,  'capybara/selenium/driver'
  end
end

Capybara.configure do |config|
  config.run_server = true
  config.server {|app, port| Capybara.run_default_server(app, port)}
  config.server_boot_timeout = 10
  config.default_selector = :css
  config.default_wait_time = 2
  config.ignore_hidden_elements = false
  config.prefer_visible_elements = true
  config.default_host = "http://www.example.com"
  config.automatic_reload = true
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end
