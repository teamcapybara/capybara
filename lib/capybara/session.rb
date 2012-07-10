module Capybara

  ##
  #
  # The Session class represents a single user's interaction with the system. The Session can use
  # any of the underlying drivers. A session can be initialized manually like this:
  #
  #     session = Capybara::Session.new(:culerity, MyRackApp)
  #
  # The application given as the second argument is optional. When running Capybara against an external
  # page, you might want to leave it out:
  #
  #     session = Capybara::Session.new(:culerity)
  #     session.visit('http://www.google.com')
  #
  # Session provides a number of methods for controlling the navigation of the page, such as +visit+,
  # +current_path, and so on. It also delegate a number of methods to a Capybara::Document, representing
  # the current HTML document. This allows interaction:
  #
  #     session.fill_in('q', :with => 'Capybara')
  #     session.click_button('Search')
  #     session.should have_content('Capybara')
  #
  # When using capybara/dsl, the Session is initialized automatically for you.
  #
  class Session
    NODE_METHODS = [
      :all, :first, :attach_file, :text, :check, :choose,
      :click_link_or_button, :click_button, :click_link, :field_labeled,
      :fill_in, :find, :find_button, :find_by_id, :find_field, :find_link,
      :has_content?, :has_text?, :has_css?, :has_no_content?, :has_no_text?,
      :has_no_css?, :has_no_xpath?, :resolve,
      :has_xpath?, :select, :uncheck, :has_link?, :has_no_link?, :has_button?,
      :has_no_button?, :has_field?, :has_no_field?, :has_checked_field?,
      :has_unchecked_field?, :has_no_table?, :has_table?, :unselect,
      :has_select?, :has_no_select?, :has_selector?, :has_no_selector?,
      :click_on, :has_no_checked_field?, :has_no_unchecked_field?, :query,
      :assert_selector, :assert_no_selector
    ]
    SESSION_METHODS = [
      :body, :html, :current_url, :current_host, :evaluate_script, :source,
      :visit, :within, :within_fieldset, :within_table,
      :within_frame, :within_window, :current_path, :save_page,
      :save_and_open_page, :reset_session!
    ]
    DSL_METHODS = NODE_METHODS + SESSION_METHODS

    attr_reader :mode, :app

    def initialize(mode, app=nil)
      @mode = mode
      @app = app
    end

    def driver
      @driver ||= begin
        unless Capybara.drivers.has_key?(mode)
          other_drivers = Capybara.drivers.keys.map { |key| key.inspect }
          raise Capybara::DriverNotFoundError, "no driver called #{mode.inspect} was found, available drivers: #{other_drivers.join(', ')}"
        end
        Capybara.drivers[mode].call(app)
      end
    end

    ##
    #
    # Reset the session, removing all cookies.
    #
    def reset!
      driver.reset! if @touched
      @touched = false
    end
    alias_method :cleanup!, :reset!
    alias_method :reset_session!, :reset!

    ##
    #
    # Returns a hash of response headers. Not supported by all drivers (e.g. Selenium)
    #
    # @return [Hash{String => String}] A hash of response headers.
    #
    def response_headers
      driver.response_headers
    end

    ##
    #
    # Returns the current HTTP status code as an Integer. Not supported by all drivers (e.g. Selenium)
    #
    # @return [Integer] Current HTTP status code
    #
    def status_code
      driver.status_code
    end

    ##
    #
    # @return [String] A snapshot of the HTML of the current document, as it looks right now (potentially modified by JavaScript).
    #
    def html
      driver.body
    end

    ##
    #
    # @return [String] HTML source of the document, before being modified by JavaScript.
    #
    def source
      driver.source
    end
    alias_method :body, :source

    ##
    #
    # @return [String] Path of the current page, without any domain information
    #
    def current_path
      path = URI.parse(current_url).path
      path if path and not path.empty?
    end

    ##
    #
    # @return [String] Host of the current page
    #
    def current_host
      uri = URI.parse(current_url)
      "#{uri.scheme}://#{uri.host}" if uri.host
    end

    ##
    #
    # @return [String] Fully qualified URL of the current page
    #
    def current_url
      driver.current_url
    end

    ##
    #
    # Navigate to the given URL. The URL can either be a relative URL or an absolute URL
    # The behaviour of either depends on the driver.
    #
    #     session.visit('/foo')
    #     session.visit('http://google.com')
    #
    # For drivers which can run against an external application, such as culerity and selenium
    # giving an absolute URL will navigate to that page. This allows testing applications
    # running on remote servers. For these drivers, setting Capybara.app_host will make the
    # remote server the default. For example:
    #
    #     Capybara.app_host = 'http://google.com'
    #     session.visit('/') # visits the google homepage
    #
    # @param [String] url     The URL to navigate to
    #
    def visit(url)
      @touched = true
      driver.visit(url)
    end

    ##
    #
    # Execute the given block for a particular scope on the page. Within will find the first
    # element matching the given selector and execute the block scoped to that element:
    #
    #     within(:xpath, '//div[@id="delivery-address"]') do
    #       fill_in('Street', :with => '12 Main Street')
    #     end
    #
    # It is possible to omit the first parameter, in that case, the selector is assumed to be
    # of the type set in Capybara.default_selector.
    #
    #     within('div#delivery-address') do
    #       fill_in('Street', :with => '12 Main Street')
    #     end
    #
    # @overload within(*find_args)
    #   @param (see Capybara::Node::Finders#all)
    #
    # @overload within(a_node)
    #   @param [Capybara::Node::Base] a_node   The node in whose scope the block should be evaluated
    #
    # @raise  [Capybara::ElementNotFound]   If the scope can't be found before time expires
    #
    def within(*args)
      new_scope = if args.size == 1 && Capybara::Node::Base === args.first
                    args.first
                  else
                    find(*args)
                  end
      begin
        scopes.push(new_scope)
        yield
      ensure
        scopes.pop
      end
    end

    ##
    #
    # Execute the given block within the a specific fieldset given the id or legend of that fieldset.
    #
    # @param [String] locator    Id or legend of the fieldset
    #
    def within_fieldset(locator)
      within :fieldset, locator do
        yield
      end
    end

    ##
    #
    # Execute the given block within the a specific table given the id or caption of that table.
    #
    # @param [String] locator    Id or caption of the table
    #
    def within_table(locator)
      within :table, locator do
        yield
      end
    end

    ##
    #
    # Execute the given block within the given iframe given the id of that iframe. Only works on
    # some drivers (e.g. Selenium)
    #
    # @param [String] frame_id   Id of the frame
    #
    def within_frame(frame_id)
      driver.within_frame(frame_id) do
        yield
      end
    end

    ##
    #
    # Execute the given block within the given window. Only works on
    # some drivers (e.g. Selenium)
    #
    # @param [String] handle of the window
    #
    def within_window(handle, &blk)
      driver.within_window(handle, &blk)
    end

    ##
    #
    # Execute the given script, not returning a result. This is useful for scripts that return
    # complex objects, such as jQuery statements. +execute_script+ should be used over
    # +evaluate_script+ whenever possible.
    #
    # @param [String] script   A string of JavaScript to execute
    #
    def execute_script(script)
      @touched = true
      driver.execute_script(script)
    end

    ##
    #
    # Evaluate the given JavaScript and return the result. Be careful when using this with
    # scripts that return complex objects, such as jQuery statements. +execute_script+ might
    # be a better alternative.
    #
    # @param  [String] script   A string of JavaScript to evaluate
    # @return [Object]          The result of the evaluated JavaScript (may be driver specific)
    #
    def evaluate_script(script)
      @touched = true
      driver.evaluate_script(script)
    end

    ##
    #
    # Save a snapshot of the page and open it in a browser for inspection
    #
    def save_page(file_name=nil)
      require 'capybara/util/save_and_open_page'
      Capybara.save_page(body, file_name)
    end

    def save_and_open_page(file_name=nil)
      require 'capybara/util/save_and_open_page'
      Capybara.save_and_open_page(body, file_name)
    end

    def document
      @document ||= Capybara::Node::Document.new(self, driver)
    end

    NODE_METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{method}(*args, &block)
          @touched = true
          current_node.send(:#{method}, *args, &block)
        end
      RUBY
    end

    def inspect
      %(#<Capybara::Session>)
    end

  private

    def current_node
      scopes.last
    end

    def scopes
      @scopes ||= [document]
    end
  end
end
