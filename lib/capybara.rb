require 'timeout'
require 'nokogiri'
require 'xpath'

module Capybara
  class CapybaraError < StandardError; end
  class DriverNotFoundError < CapybaraError; end
  class FrozenInTime < CapybaraError; end
  class ElementNotFound < CapybaraError; end
  class ModalNotFound < CapybaraError; end
  class Ambiguous < ElementNotFound; end
  class ExpectationNotMet < ElementNotFound; end
  class FileNotFound < CapybaraError; end
  class UnselectNotAllowed < CapybaraError; end
  class NotSupportedByDriverError < CapybaraError; end
  class InfiniteRedirectError < CapybaraError; end
  class ScopeError < CapybaraError; end
  class WindowError < CapybaraError; end
  class ReadOnlyElementError < CapybaraError; end

  class << self
    attr_accessor :asset_host, :app_host, :run_server, :default_host, :always_include_port
    attr_accessor :server_port, :exact, :match, :exact_options, :visible_text_only
    attr_accessor :default_selector, :default_max_wait_time, :ignore_hidden_elements
    attr_accessor :save_and_open_page_path, :wait_on_first_by_default, :automatic_reload, :raise_server_errors, :server_errors
    attr_writer :default_driver, :current_driver, :javascript_driver, :session_name, :server_host
    attr_accessor :app

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
    # [app_host = String]                 The default host to use when giving a relative URL to visit  
    # [always_include_port = Boolean]     Whether the Rack server's port should automatically be inserted into every visited URL (Default: false)  
    # [asset_host = String]               Where dynamic assets are hosted - will be prepended to relative asset locations if present (Default: nil)  
    # [run_server = Boolean]              Whether to start a Rack server for the given Rack app (Default: true)  
    # [raise_server_errors = Boolean]     Should errors raised in the server be raised in the tests? (Default: true)  
    # [server_errors = Array\<Class\>]    Error classes that should be raised in the tests if they are raised in the server and Capybara.raise_server_errors is true (Default: [StandardError])  
    # [default_selector = :css/:xpath]    Methods which take a selector use the given type by default (Default: :css)  
    # [default_max_wait_time = Numeric]   The maximum number of seconds to wait for asynchronous processes to finish (Default: 2)  
    # [ignore_hidden_elements = Boolean]  Whether to ignore hidden elements on the page (Default: true)  
    # [automatic_reload = Boolean]        Whether to automatically reload elements as Capybara is waiting (Default: true)  
    # [save_and_open_page_path = String]  Where to put pages saved through save_and_open_page (Default: Dir.pwd)  
    # [wait_on_first_by_default = Boolean]   Whether Node#first defaults to Capybara waiting behavior for at least 1 element to match (Default: false) 
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
    #       Capybara::RackTest::Driver.new(app)
    #     end
    #
    # @param [Symbol] name                    The name of the new driver
    # @yield [app]                            This block takes a rack app and returns a Capybara driver
    # @yieldparam [<Rack>] app                The rack application that this driver runs against. May be nil.
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
    #     within(:row, 3) { expect(page).to have_content('$100.000') }
    #
    # Here is another example:
    #
    #     Capybara.add_selector(:id) do
    #       xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
    #     end
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
    # By default, Capybara will try to run webrick.
    #
    # @yield [app, port]                      This block receives a rack app and port and should run a Rack handler
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
    # in a {Capybara::Node::Simple} which exposes all {Capybara::Node::Matchers},
    # {Capybara::Node::Finders} and {Capybara::Node::DocumentMatchers}. This allows you to query
    # any string containing HTML in the exact same way you would query the current document in a Capybara
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
    #     node.has_selector?('#projects')
    #     node.find('ul').find('li:first-child').text # => 'Home'
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
      require 'rack/handler/webrick'
      Rack::Handler::WEBrick.run(app, :Host => server_host, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
    end

    ##
    #
    # @return [Symbol]    The name of the driver to use by default
    #
    def default_driver
      @default_driver || :rack_test
    end

    ##
    #
    # @return [Symbol]    The name of the driver currently in use
    #
    def current_driver
      @current_driver || default_driver
    end
    alias_method :mode, :current_driver

    ##
    #
    # @return [Symbol]    The name of the driver used when JavaScript is needed
    #
    def javascript_driver
      @javascript_driver || :selenium
    end

    ##
    #
    # Use the default driver as the current driver
    #
    def use_default_driver
      @current_driver = nil
    end

    ##
    #
    # Yield a block using a specific driver
    #
    def using_driver(driver)
      previous_driver = Capybara.current_driver
      Capybara.current_driver = driver
      yield
    ensure
      @current_driver = previous_driver
    end

    ##
    #
    # @return [String]    The IP address bound by default server
    #
    def server_host
      @server_host || '127.0.0.1'
    end

    ##
    #
    # Yield a block using a specific wait time
    #
    def using_wait_time(seconds)
      previous_wait_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = seconds
      yield
    ensure
      Capybara.default_max_wait_time = previous_wait_time
    end

    ##
    #
    # The current Capybara::Session based on what is set as Capybara.app and Capybara.current_driver
    #
    # @return [Capybara::Session]     The currently used session
    #
    def current_session
      session_pool["#{current_driver}:#{session_name}:#{app.object_id}"] ||= Capybara::Session.new(current_driver, app)
    end

    ##
    #
    # Reset sessions, cleaning out the pool of sessions. This will remove any session information such
    # as cookies.
    #
    def reset_sessions!
      session_pool.each { |mode, session| session.reset! }
    end
    alias_method :reset!, :reset_sessions!

    ##
    #
    # The current session name.
    #
    # @return [Symbol]    The name of the currently used session.
    #
    def session_name
      @session_name ||= :default
    end

    ##
    #
    # Yield a block using a specific session name.
    #
    def using_session(name)
      previous_session_name = self.session_name
      self.session_name = name
      yield
    ensure
      self.session_name = previous_session_name
    end

    ##
    #
    # Parse raw html into a document using Nokogiri, and adjust textarea contents as defined by the spec.
    #
    # @param [String] html              The raw html
    # @return [Nokogiri::HTML::Document]      HTML document
    #
    def HTML(html)
      Nokogiri::HTML(html).tap do |document|
        document.xpath('//textarea').each do |textarea|
          textarea.content=textarea.content.sub(/\A\n/,'')
        end
      end
    end
    
    # @deprecated Use default_max_wait_time instead
    def default_wait_time
      deprecate('default_wait_time', 'default_max_wait_time', true)
      default_max_wait_time
    end
    
    # @deprecated Use default_max_wait_time= instead
    def default_wait_time=(t)
      deprecate('default_wait_time=', 'default_max_wait_time=')
      self.default_max_wait_time = t
    end

    def included(base)
      base.send(:include, Capybara::DSL)
      warn "`include Capybara` is deprecated. Please use `include Capybara::DSL` instead."
    end

    def deprecate(method, alternate_method, once=false)
      @deprecation_notified ||= {}
      warn "DEPRECATED: ##{method} is deprecated, please use ##{alternate_method} instead" unless once and @deprecation_notified[method]
      @deprecation_notified[method]=true
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  self.default_driver = nil
  self.current_driver = nil
  self.server_host = nil

  module Driver; end
  module RackTest; end
  module Selenium; end

  require 'capybara/helpers'
  require 'capybara/session'
  require 'capybara/dsl'
  require 'capybara/window'
  require 'capybara/server'
  require 'capybara/selector'
  require 'capybara/result'
  require 'capybara/version'

  require 'capybara/queries/base_query'
  require 'capybara/query'
  require 'capybara/queries/text_query'
  require 'capybara/queries/title_query'
  require 'capybara/queries/current_path_query'
  
  require 'capybara/node/finders'
  require 'capybara/node/matchers'
  require 'capybara/node/actions'
  require 'capybara/node/document_matchers'
  require 'capybara/node/simple'
  require 'capybara/node/base'
  require 'capybara/node/element'
  require 'capybara/node/document'

  require 'capybara/driver/base'
  require 'capybara/driver/node'

  require 'capybara/rack_test/driver'
  require 'capybara/rack_test/node'
  require 'capybara/rack_test/form'
  require 'capybara/rack_test/browser'
  require 'capybara/rack_test/css_handlers.rb'

  require 'capybara/selenium/node'
  require 'capybara/selenium/driver'
end

Capybara.configure do |config|
  config.always_include_port = false
  config.run_server = true
  config.server {|app, port| Capybara.run_default_server(app, port)}
  config.default_selector = :css
  config.default_max_wait_time = 2
  config.ignore_hidden_elements = true
  config.default_host = "http://www.example.com"
  config.automatic_reload = true
  config.match = :smart
  config.exact = false
  config.raise_server_errors = true
  config.server_errors = [StandardError]
  config.visible_text_only = false
  config.wait_on_first_by_default = false
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end
