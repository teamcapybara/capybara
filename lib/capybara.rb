# frozen_string_literal: true

require 'timeout'
require 'nokogiri'
require 'xpath'
require 'forwardable'
require 'capybara/config'

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
    extend Forwardable

    # DelegateCapybara global configurations
    # @!method app
    #   See {Capybara.configure}
    # @!method reuse_server
    #   See {Capybara.configure}
    # @!method threadsafe
    #   See {Capybara.configure}
    # @!method server
    #   See {Capybara.configure}
    # @!method default_driver
    #   See {Capybara.configure}
    # @!method javascript_driver
    #   See {Capybara.configure}
    # @!method allow_gumbo
    #   See {Capybara.configure}
    Config::OPTIONS.each do |method|
      def_delegators :config, method, "#{method}="
    end

    # Delegate Capybara global configurations
    # @!method default_selector
    #   See {Capybara.configure}
    # @!method default_max_wait_time
    #   See {Capybara.configure}
    # @!method app_host
    #   See {Capybara.configure}
    # @!method always_include_port
    #   See {Capybara.configure}
    SessionConfig::OPTIONS.each do |method|
      def_delegators :config, method, "#{method}="
    end

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
    # [app_host = String/nil]             The default host to use when giving a relative URL to visit, must be a valid URL e.g. http://www.example.com
    # [always_include_port = Boolean]     Whether the Rack server's port should automatically be inserted into every visited URL unless another port is explicitly specified (Default: false)
    # [asset_host = String]               Where dynamic assets are hosted - will be prepended to relative asset locations if present (Default: nil)
    # [run_server = Boolean]              Whether to start a Rack server for the given Rack app (Default: true)
    # [raise_server_errors = Boolean]     Should errors raised in the server be raised in the tests? (Default: true)
    # [server_errors = Array\<Class\>]    Error classes that should be raised in the tests if they are raised in the server and {configure raise_server_errors} is true (Default: [Exception])
    # [default_selector = :css/:xpath]    Methods which take a selector use the given type by default (Default: :css)
    # [default_max_wait_time = Numeric]   The maximum number of seconds to wait for asynchronous processes to finish (Default: 2)
    # [ignore_hidden_elements = Boolean]  Whether to ignore hidden elements on the page (Default: true)
    # [automatic_reload = Boolean]        Whether to automatically reload elements as Capybara is waiting (Default: true)
    # [save_path = String]  Where to put pages saved through save_(page|screenshot), save_and_open_(page|screenshot) (Default: Dir.pwd)
    # [automatic_label_click = Boolean]   Whether {Capybara::Node::Element#choose Element#choose}, {Capybara::Node::Element#check Element#check}, {Capybara::Node::Element#uncheck Element#uncheck} will attempt to click the associated label element if the checkbox/radio button are non-visible (Default: false)
    # [enable_aria_label = Boolean]  Whether fields, links, and buttons will match against aria-label attribute (Default: false)
    # [reuse_server = Boolean]  Reuse the server thread between multiple sessions using the same app object (Default: true)
    # [threadsafe = Boolean]  Whether sessions can be configured individually (Default: false)
    # [server = Symbol]  The name of the registered server to use when running the app under test (Default: :default which uses puma)
    # [default_set_options = Hash]  The default options passed to {Capybara::Node::Element#set Element#set} (Default: {})
    # [test_id = Symbol/String/nil] Optional attribute to match locator aginst with builtin selectors along with id (Default: nil)
    # [predicates_wait = Boolean]  Whether Capybara's predicate matchers use waiting behavior by default (Default: true)
    # [default_normalize_ws = Boolean] Whether text predicates and matchers use normalize whitespace behaviour (Default: false)
    # [allow_gumbo = Boolean] When `nokogumbo` is available, whether it will be used to parse HTML strings (Default: false)
    # [match = :one/:first/:prefer_exact/:smart] The matching strategy to find nodes (Default: :smart)
    # [exact_text = Boolean] Whether the text matchers and `:text` filter match exactly or on substrings (Default: false)
    #
    # === DSL Options
    #
    # when using capybara/dsl, the following options are also available:
    #
    # [default_driver = Symbol]           The name of the driver to use by default. (Default: :rack_test)
    # [javascript_driver = Symbol]        The name of a driver to use for JavaScript enabled tests. (Default: :selenium)
    #
    def configure
      yield config
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
    # Register a new server for Capybara.
    #
    #     Capybara.register_server :webrick do |app, port, host|
    #       require 'rack/handler/webrick'
    #       Rack::Handler::WEBrick.run(app, ...)
    #     end
    #
    # @param [Symbol] name                    The name of the new driver
    # @yield [app, port, host]                This block takes a rack app and a port and returns a rack server listening on that port
    # @yieldparam [<Rack>] app                The rack application that this server will contain.
    # @yieldparam port                        The port number the server should listen on
    # @yieldparam host                        The host/ip to bind to
    #
    def register_server(name, &block)
      servers[name.to_sym] = block
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
    def add_selector(name, **options, &block)
      Capybara::Selector.add(name, **options, &block)
    end

    ##
    #
    # Modify a selector previously created by {Capybara.add_selector}.
    # For example, adding a new filter to the :button selector to filter based on
    # button style (a class) might look like this
    #
    #     Capybara.modify_selector(:button) do
    #       filter (:btn_style, valid_values: [:primary, :secondary]) { |node, style| node[:class].split.include? "btn-#{style}" }
    #     end
    #
    #
    # @param [Symbol] name    The name of the selector to modify
    # @yield                  A block executed in the context of the existing {Capybara::Selector}
    #
    def modify_selector(name, &block)
      Capybara::Selector.update(name, &block)
    end

    def drivers
      @drivers ||= {}
    end

    def servers
      @servers ||= {}
    end

    # Wraps the given string, which should contain an HTML document or fragment
    # in a {Capybara::Node::Simple} which exposes all {Capybara::Node::Matchers},
    # {Capybara::Node::Finders} and {Capybara::Node::DocumentMatchers}. This allows you to query
    # any string containing HTML in the exact same way you would query the current document in a Capybara
    # session.
    #
    # @example A single element
    #     node = Capybara.string('<a href="foo">bar</a>')
    #     anchor = node.first('a')
    #     anchor[:href] #=> 'foo'
    #     anchor.text #=> 'bar'
    #
    # @example Multiple elements
    #     node = Capybara.string <<-HTML
    #       <ul>
    #         <li id="home">Home</li>
    #         <li id="projects">Projects</li>
    #       </ul>
    #     HTML
    #
    #     node.find('#projects').text # => 'Projects'
    #     node.has_selector?('li#home', text: 'Home')
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
    # @param [Integer] port              The port to run the application on
    #
    def run_default_server(app, port)
      servers[:puma].call(app, port, server_host)
    end

    ##
    #
    # @return [Symbol]    The name of the driver currently in use
    #
    def current_driver
      if threadsafe
        Thread.current['capybara_current_driver']
      else
        @current_driver
      end || default_driver
    end
    alias_method :mode, :current_driver

    def current_driver=(name)
      if threadsafe
        Thread.current['capybara_current_driver'] = name
      else
        @current_driver = name
      end
    end

    ##
    #
    # Use the default driver as the current driver
    #
    def use_default_driver
      self.current_driver = nil
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
      self.current_driver = previous_driver
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
    # The current {Capybara::Session} based on what is set as {app} and {current_driver}.
    #
    # @return [Capybara::Session]     The currently used session
    #
    def current_session
      specified_session || session_pool["#{current_driver}:#{session_name}:#{app.object_id}"]
    end

    ##
    #
    # Reset sessions, cleaning out the pool of sessions. This will remove any session information such
    # as cookies.
    #
    def reset_sessions!
      # reset in reverse so sessions that started servers are reset last
      session_pool.reverse_each { |_mode, session| session.reset! }
    end
    alias_method :reset!, :reset_sessions!

    ##
    #
    # The current session name.
    #
    # @return [Symbol]    The name of the currently used session.
    #
    def session_name
      if threadsafe
        Thread.current['capybara_session_name'] ||= :default
      else
        @session_name ||= :default
      end
    end

    def session_name=(name)
      if threadsafe
        Thread.current['capybara_session_name'] = name
      else
        @session_name = name
      end
    end

    ##
    #
    # Yield a block using a specific session name or {Capybara::Session} instance.
    #
    def using_session(name_or_session)
      previous_session_info = {
        specified_session: specified_session,
        session_name: session_name,
        current_driver: current_driver,
        app: app
      }
      self.specified_session = self.session_name = nil
      if name_or_session.is_a? Capybara::Session
        self.specified_session = name_or_session
      else
        self.session_name = name_or_session
      end
      yield
    ensure
      self.session_name, self.specified_session = previous_session_info.values_at(:session_name, :specified_session)
      self.current_driver, self.app = previous_session_info.values_at(:current_driver, :app) if threadsafe
    end

    ##
    #
    # Parse raw html into a document using Nokogiri, and adjust textarea contents as defined by the spec.
    #
    # @param [String] html              The raw html
    # @return [Nokogiri::HTML::Document]      HTML document
    #
    def HTML(html) # rubocop:disable Naming/MethodName
      if Nokogiri.respond_to?(:HTML5) && Capybara.allow_gumbo # Nokogumbo installed and allowed for use
        Nokogiri::HTML5(html).tap do |document|
          document.xpath('//template').each do |template|
            # template elements content is not part of the document
            template.inner_html = ''
          end
          document.xpath('//textarea').each do |textarea|
            # The Nokogumbo HTML5 parser already returns spec compliant contents
            textarea['_capybara_raw_value'] = textarea.content
          end
        end
      else
        Nokogiri::HTML(html).tap do |document|
          document.xpath('//template').each do |template|
            # template elements content is not part of the document
            template.inner_html = ''
          end
          document.xpath('//textarea').each do |textarea|
            textarea['_capybara_raw_value'] = textarea.content.sub(/\A\n/, '')
          end
        end
      end
    end

    def session_options
      config.session_options
    end

  private

    def config
      @config ||= Capybara::Config.new
    end

    def session_pool
      @session_pool ||= Hash.new do |hash, name|
        hash[name] = Capybara::Session.new(current_driver, app)
      end
    end

    def specified_session
      if threadsafe
        Thread.current['capybara_specified_session']
      else
        @specified_session ||= nil
      end
    end

    def specified_session=(session)
      if threadsafe
        Thread.current['capybara_specified_session'] = session
      else
        @specified_session = session
      end
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
  require 'capybara/window'
  require 'capybara/server'
  require 'capybara/selector'
  require 'capybara/result'
  require 'capybara/version'

  require 'capybara/queries/base_query'
  require 'capybara/queries/selector_query'
  require 'capybara/queries/text_query'
  require 'capybara/queries/title_query'
  require 'capybara/queries/current_path_query'
  require 'capybara/queries/match_query'
  require 'capybara/queries/ancestor_query'
  require 'capybara/queries/sibling_query'
  require 'capybara/queries/style_query'

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

require 'capybara/registrations/servers'
require 'capybara/registrations/drivers'

Capybara.configure do |config|
  config.always_include_port = false
  config.run_server = true
  config.server = :default
  config.default_selector = :css
  config.default_max_wait_time = 2
  config.ignore_hidden_elements = true
  config.default_host = 'http://www.example.com'
  config.automatic_reload = true
  config.match = :smart
  config.exact = false
  config.exact_text = false
  config.raise_server_errors = true
  config.server_errors = [Exception]
  config.visible_text_only = false
  config.automatic_label_click = false
  config.enable_aria_label = false
  config.reuse_server = true
  config.default_set_options = {}
  config.test_id = nil
  config.predicates_wait = true
  config.default_normalize_ws = false
  config.allow_gumbo = false
end
