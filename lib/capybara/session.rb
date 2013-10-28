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
      :has_no_css?, :has_no_xpath?, :resolve, :has_xpath?, :select, :uncheck,
      :has_link?, :has_no_link?, :has_button?, :has_no_button?, :has_field?,
      :has_no_field?, :has_checked_field?, :has_unchecked_field?,
      :has_no_table?, :has_table?, :unselect, :has_select?, :has_no_select?,
      :has_selector?, :has_no_selector?, :click_on, :has_no_checked_field?,
      :has_no_unchecked_field?, :query, :assert_selector, :assert_no_selector
    ]
    SESSION_METHODS = [
      :body, :html, :source, :current_url, :current_host, :current_path,
      :execute_script, :evaluate_script, :visit, :go_back, :go_forward,
      :within, :within_fieldset, :within_table, :within_frame, :within_window,
      :save_page, :save_and_open_page, :save_screenshot,
      :reset_session!, :response_headers, :status_code,
      :title, :has_title?, :has_no_title?, :current_scope
    ]
    DSL_METHODS = NODE_METHODS + SESSION_METHODS

    attr_reader :mode, :app, :server
    attr_accessor :synchronized

    def initialize(mode, app=nil)
      @mode = mode
      @app = app
      if Capybara.run_server and @app and driver.needs_server?
        @server = Capybara::Server.new(@app).boot
      else
        @server = nil
      end
      @touched = false
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
      if @touched
        driver.reset!
        @touched = false
        assert_no_selector :xpath, "/html/body/*"
      end
      raise @server.error if Capybara.raise_server_errors and @server and @server.error
    ensure
      @server.reset_error! if @server
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
    # @return [String] A snapshot of the DOM of the current document, as it looks right now (potentially modified by JavaScript).
    #
    def html
      driver.html
    end
    alias_method :body, :html
    alias_method :source, :html

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
    # @return [String] Title of the current page
    #
    def title
      driver.title
    end

    ##
    #
    # Navigate to the given URL. The URL can either be a relative URL or an absolute URL
    # The behaviour of either depends on the driver.
    #
    #     session.visit('/foo')
    #     session.visit('http://google.com')
    #
    # For drivers which can run against an external application, such as the selenium driver
    # giving an absolute URL will navigate to that page. This allows testing applications
    # running on remote servers. For these drivers, setting {Capybara.app_host} will make the
    # remote server the default. For example:
    #
    #     Capybara.app_host = 'http://google.com'
    #     session.visit('/') # visits the google homepage
    #
    # If {Capybara.always_include_port} is set to true and this session is running against
    # a rack application, then the port that the rack application is running on will automatically
    # be inserted into the URL. Supposing the app is running on port `4567`, doing something like:
    #
    #     visit("http://google.com/test")
    #
    # Will actually navigate to `http://google.com:4567/test`.
    #
    # @param [String] url     The URL to navigate to
    #
    def visit(url)
      @touched = true

      if url !~ /^http/ and Capybara.app_host
        url = Capybara.app_host + url.to_s
      end

      if @server
        url = "http://#{@server.host}:#{@server.port}" + url.to_s unless url =~ /^http/

        if Capybara.always_include_port
          uri = URI.parse(url)
          uri.port = @server.port if uri.port == uri.default_port
          url = uri.to_s
        end
      end

      driver.visit(url)
    end

    ##
    #
    # Move back a single entry in the browser's history.
    #
    def go_back
      driver.go_back
    end

    ##
    #
    # Move forward a single entry in the browser's history.
    #
    def go_forward
      driver.go_forward
    end

    ##
    #
    # Executes the given block within the context of a node. `within` takes the
    # same options as `find`, as well as a block. For the duration of the
    # block, any command to Capybara will be handled as though it were scoped
    # to the given element.
    #
    #     within(:xpath, '//div[@id="delivery-address"]') do
    #       fill_in('Street', :with => '12 Main Street')
    #     end
    #
    # Just as with `find`, if multiple elements match the selector given to
    # `within`, an error will be raised, and just as with `find`, this
    # behaviour can be controlled through the `:match` and `:exact` options.
    #
    # It is possible to omit the first parameter, in that case, the selector is
    # assumed to be of the type set in Capybara.default_selector.
    #
    #     within('div#delivery-address') do
    #       fill_in('Street', :with => '12 Main Street')
    #     end
    #
    # Note that a lot of uses of `within` can be replaced more succinctly with
    # chaining:
    #
    #     find('div#delivery-address').fill_in('Street', :with => '12 Main Street')
    #
    # @overload within(*find_args)
    #   @param (see Capybara::Node::Finders#all)
    #
    # @overload within(a_node)
    #   @param [Capybara::Node::Base] a_node   The node in whose scope the block should be evaluated
    #
    # @raise  [Capybara::ElementNotFound]      If the scope can't be found before time expires
    #
    def within(*args)
      new_scope = if args.first.is_a?(Capybara::Node::Base) then args.first else find(*args) end
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
    # Execute the given block within the given iframe using given frame name or index.
    # May be supported by not all drivers. Drivers that support it, may provide additional options.
    #
    # @overload within_frame(index)
    #   @param [Integer] index         index of a frame
    # @overload within_frame(name)
    #   @param [String] name           name of a frame
    #
    def within_frame(frame_handle)
      scopes.push(nil)
      driver.within_frame(frame_handle) do
        yield
      end
    ensure
      scopes.pop
    end

    ##
    #
    # Execute the given block within the given window. Only works on
    # some drivers (e.g. Selenium)
    #
    # @param [String] handle of the window
    #
    def within_window(handle, &blk)
      scopes.push(nil)
      driver.within_window(handle, &blk)
    ensure
      scopes.pop
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
    # Save a snapshot of the page.
    #
    # @param  [String] path     The path to where it should be saved [optional]
    #
    def save_page(path=nil)
      path ||= "capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10**10)}.html"
      path = File.expand_path(path, Capybara.save_and_open_page_path)

      FileUtils.mkdir_p(File.dirname(path))

      File.open(path,'w') { |f| f.write(Capybara::Helpers.inject_asset_host(body)) }
      path
    end

    ##
    #
    # Save a snapshot of the page and open it in a browser for inspection
    #
    # @param  [String] file_name  The path to where it should be saved [optional]
    #
    def save_and_open_page(file_name=nil)
      file_name = save_page(file_name)

      begin
        require "launchy"
        Launchy.open(file_name)
      rescue LoadError
        warn "Page saved to #{file_name} with save_and_open_page."
        warn "Please install the launchy gem to open page automatically."
      end
    end

    ##
    #
    # Save a screenshot of page
    #
    # @param  [String] path    A string of image path
    # @option [Hash]   options Options for saving screenshot
    def save_screenshot(path, options={})
      driver.save_screenshot(path, options)
    end

    def document
      @document ||= Capybara::Node::Document.new(self, driver)
    end

    NODE_METHODS.each do |method|
      define_method method do |*args, &block|
        @touched = true
        current_scope.send(method, *args, &block)
      end
    end

    def inspect
      %(#<Capybara::Session>)
    end

    def has_title?(content)
      document.synchronize do
        unless title.match(Capybara::Helpers.to_regexp(content))
          raise ExpectationNotMet
        end
      end
      return true
    rescue Capybara::ExpectationNotMet
      return false
    end

    def has_no_title?(content)
      document.synchronize do
        if title.match(Capybara::Helpers.to_regexp(content))
          raise ExpectationNotMet
        end
      end
      return true
    rescue Capybara::ExpectationNotMet
      return false
    end

    def current_scope
      scopes.last || document
    end

  private

    def scopes
      @scopes ||= [document]
    end
  end
end
