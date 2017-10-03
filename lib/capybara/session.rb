# frozen_string_literal: true
require 'capybara/session/matchers'
require 'addressable/uri'

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
  # When Capybara.threadsafe == true the sessions options will be initially set to the
  # current values of the global options and a configuration block can be passed to the session initializer.
  # For available options see {Capybara::SessionConfig::OPTIONS}
  #
  #     session = Capybara::Session.new(:driver, MyRackApp) do |config|
  #       config.app_host = "http://my_host.dev"
  #     end
  #
  # Session provides a number of methods for controlling the navigation of the page, such as +visit+,
  # +current_path, and so on. It also delegate a number of methods to a Capybara::Document, representing
  # the current HTML document. This allows interaction:
  #
  #     session.fill_in('q', with: 'Capybara')
  #     session.click_button('Search')
  #     expect(session).to have_content('Capybara')
  #
  # When using capybara/dsl, the Session is initialized automatically for you.
  #
  class Session
    include Capybara::SessionMatchers

    NODE_METHODS = [
      :all, :first, :attach_file, :text, :check, :choose,
      :click_link_or_button, :click_button, :click_link, :field_labeled,
      :fill_in, :find, :find_all, :find_button, :find_by_id, :find_field, :find_link,
      :has_content?, :has_text?, :has_css?, :has_no_content?, :has_no_text?,
      :has_no_css?, :has_no_xpath?, :resolve, :has_xpath?, :select, :uncheck,
      :has_link?, :has_no_link?, :has_button?, :has_no_button?, :has_field?,
      :has_no_field?, :has_checked_field?, :has_unchecked_field?,
      :has_no_table?, :has_table?, :unselect, :has_select?, :has_no_select?,
      :has_selector?, :has_no_selector?, :click_on, :has_no_checked_field?,
      :has_no_unchecked_field?, :query, :assert_selector, :assert_no_selector,
      :assert_all_of_selectors, :assert_none_of_selectors,
      :refute_selector, :assert_text, :assert_no_text
    ]
    # @api private
    DOCUMENT_METHODS = [
      :title, :assert_title, :assert_no_title, :has_title?, :has_no_title?
    ]
    SESSION_METHODS = [
      :body, :html, :source, :current_url, :current_host, :current_path,
      :execute_script, :evaluate_script, :visit, :refresh, :go_back, :go_forward,
      :within, :within_element, :within_fieldset, :within_table, :within_frame, :switch_to_frame,
      :current_window, :windows, :open_new_window, :switch_to_window, :within_window, :window_opened_by,
      :save_page, :save_and_open_page, :save_screenshot,
      :save_and_open_screenshot, :reset_session!, :response_headers,
      :status_code, :current_scope,
      :assert_current_path, :assert_no_current_path, :has_current_path?, :has_no_current_path?
    ] + DOCUMENT_METHODS
    MODAL_METHODS = [
      :accept_alert, :accept_confirm, :dismiss_confirm, :accept_prompt,
      :dismiss_prompt
    ]
    DSL_METHODS = NODE_METHODS + SESSION_METHODS + MODAL_METHODS

    attr_reader :mode, :app, :server
    attr_accessor :synchronized

    def initialize(mode, app=nil)
      raise TypeError, "The second parameter to Session::new should be a rack app if passed." if app && !app.respond_to?(:call)
      @@instance_created = true
      @mode = mode
      @app = app
      if block_given?
        raise "A configuration block is only accepted when Capybara.threadsafe == true" unless Capybara.threadsafe
        yield config if block_given?
      end
      if config.run_server and @app and driver.needs_server?
        @server = Capybara::Server.new(@app, config.server_port, config.server_host, config.server_errors).boot
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
        driver = Capybara.drivers[mode].call(app)
        driver.session = self if driver.respond_to?(:session=)
        driver
      end
    end

    ##
    #
    # Reset the session (i.e. remove cookies and navigate to blank page)
    #
    # This method does not:
    #
    #   * accept modal dialogs if they are present (Selenium driver now does, others may not)
    #   * clear browser cache/HTML 5 local storage/IndexedDB/Web SQL database/etc.
    #   * modify state of the driver/underlying browser in any other way
    #
    # as doing so will result in performance downsides and it's not needed to do everything from the list above for most apps.
    #
    # If you want to do anything from the list above on a general basis you can:
    #
    #   * write RSpec/Cucumber/etc. after hook
    #   * monkeypatch this method
    #   * use Ruby's `prepend` method
    #
    def reset!
      if @touched
        driver.reset!
        @touched = false
      end
      @server.wait_for_pending_requests if @server
      raise_server_error!
    end
    alias_method :cleanup!, :reset!
    alias_method :reset_session!, :reset!

    ##
    #
    # Raise errors encountered in the server
    #
    def raise_server_error!
      if @server and @server.error
        # Force an explanation for the error being raised as the exception cause
        begin
          if config.raise_server_errors
            raise CapybaraError, "Your application server raised an error - It has been raised in your test code because Capybara.raise_server_errors == true"
          end
        rescue CapybaraError
          #needed to get the cause set correctly in JRuby -- otherwise we could just do raise @server.error
          raise @server.error, @server.error.message, @server.error.backtrace
        ensure
          @server.reset_error!
        end
      end
    end

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
      # Addressable parsing is more lenient than URI
      uri = ::Addressable::URI.parse(current_url)

      # If current_url ends up being nil, won't be able to call .path on a NilClass.
      return nil if uri.nil?

      # Addressable doesn't support opaque URIs - we want nil here
      return nil if uri.scheme == "about"
      path = uri.path
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
    # @param [#to_s] visit_uri     The URL to navigate to. The parameter will be cast to a String.
    #
    def visit(visit_uri)
      raise_server_error!
      @touched = true

      visit_uri = ::Addressable::URI.parse(visit_uri.to_s)

      uri_base = if @server
        ::Addressable::URI.parse(config.app_host || "http://#{@server.host}:#{@server.port}")
      else
        config.app_host && ::Addressable::URI.parse(config.app_host)
      end

      uri_base.port ||= @server.port if @server && config.always_include_port

      if uri_base && [nil, 'http', 'https'].include?(visit_uri.scheme)
        visit_uri_parts = visit_uri.to_hash.delete_if { |k,v| v.nil? }

        if visit_uri.scheme.nil?
          # TODO - this is only for compatability with previous 2.x behavior that concatenated
          # Capybara.app_host and a "relative" path - Consider removing in 3.0
          # @abotalov brought up a good point about this behavior potentially being useful to people
          # deploying to a subdirectory and/or single page apps where only the url fragment changes
          visit_uri_parts[:path] = uri_base.path + visit_uri.path
        end

        visit_uri = uri_base.merge(visit_uri_parts)
      end
      driver.visit(visit_uri.to_s)
    end

    ##
    #
    # Refresh the page
    #
    def refresh
      raise_server_error!
      driver.refresh
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
    #     within(:xpath, './/div[@id="delivery-address"]') do
    #       fill_in('Street', with: '12 Main Street')
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
    #       fill_in('Street', with: '12 Main Street')
    #     end
    #
    # Note that a lot of uses of `within` can be replaced more succinctly with
    # chaining:
    #
    #     find('div#delivery-address').fill_in('Street', with: '12 Main Street')
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
    alias_method :within_element, :within

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
    # Switch to the given frame
    #
    # If you use this method you are responsible for making sure you switch back to the parent frame when done in the frame changed to.
    # Capybara::Session#within_frame is preferred over this method and should be used when possible.
    # May not be supported by all drivers.
    #
    # @overload switch_to_frame(element)
    #   @param [Capybara::Node::Element]  iframe/frame element to switch to
    # @overload switch_to_frame(:parent)
    #   Switch to the parent element
    # @overload switch_to_frame(:top)
    #   Switch to the top level document
    #
    def switch_to_frame(frame)
      case frame
      when Capybara::Node::Element
        driver.switch_to_frame(frame)
        scopes.push(:frame)
      when :parent
        raise Capybara::ScopeError, "`switch_to_frame(:parent)` cannot be called from inside a descendant frame's "\
                                    "`within` block." if scopes.last() != :frame
        scopes.pop
        driver.switch_to_frame(:parent)
      when :top
        idx = scopes.index(:frame)
        if idx
          raise Capybara::ScopeError, "`switch_to_frame(:top)` cannot be called from inside a descendant frame's "\
                                      "`within` block." if scopes.slice(idx..-1).any? {|scope| ![:frame, nil].include?(scope)}
          scopes.slice!(idx..-1)
          driver.switch_to_frame(:top)
        end
      end
    end

    ##
    #
    # Execute the given block within the given iframe using given frame, frame name/id or index.
    # May not be supported by all drivers.
    #
    # @overload within_frame(element)
    #   @param [Capybara::Node::Element]  frame element
    # @overload within_frame([kind = :frame], locator, options = {})
    #   @param [Symobl] kind      Optional selector type (:css, :xpath, :field, etc.) - Defaults to :frame
    #   @param [String] locator   The locator for the given selector kind.  For :frame this is the name/id of a frame/iframe element
    # @overload within_frame(index)
    #   @param [Integer] index         index of a frame (0 based)
    def within_frame(*args)
      frame = _find_frame(*args)

      begin
        switch_to_frame(frame)
        begin
          yield
        ensure
          switch_to_frame(:parent)
        end
      rescue Capybara::NotSupportedByDriverError
        # Support older driver frame API for now
        if driver.respond_to?(:within_frame)
          begin
            scopes.push(:frame)
            driver.within_frame(frame) do
              yield
            end
          ensure
            scopes.pop
          end
        else
          raise
        end
      end
    end

    ##
    # @return [Capybara::Window]   current window
    #
    def current_window
      Window.new(self, driver.current_window_handle)
    end

    ##
    # Get all opened windows.
    # The order of windows in returned array is not defined.
    # The driver may sort windows by their creation time but it's not required.
    #
    # @return [Array<Capybara::Window>]   an array of all windows
    #
    def windows
      driver.window_handles.map do |handle|
        Window.new(self, handle)
      end
    end

    ##
    # Open new window.
    # Current window doesn't change as the result of this call.
    # It should be switched to explicitly.
    #
    # @return [Capybara::Window]   window that has been opened
    #
    def open_new_window
      window_opened_by do
        driver.open_new_window
      end
    end

    ##
    # @overload switch_to_window(&block)
    #   Switches to the first window for which given block returns a value other than false or nil.
    #   If window that matches block can't be found, the window will be switched back and `WindowError` will be raised.
    #   @example
    #     window = switch_to_window { title == 'Page title' }
    #   @raise [Capybara::WindowError]     if no window matches given block
    # @overload switch_to_window(window)
    #   @param window [Capybara::Window]   window that should be switched to
    #   @raise [Capybara::Driver::Base#no_such_window_error] if non-existent (e.g. closed) window was passed
    #
    # @return [Capybara::Window]         window that has been switched to
    # @raise [Capybara::ScopeError]        if this method is invoked inside `within` or
    #   `within_frame` methods
    # @raise [ArgumentError]               if both or neither arguments were provided
    #
    def switch_to_window(window = nil, options= {}, &window_locator)
      options, window = window, nil if window.is_a? Hash

      block_given = block_given?
      if window && block_given
        raise ArgumentError, "`switch_to_window` can take either a block or a window, not both"
      elsif !window && !block_given
        raise ArgumentError, "`switch_to_window`: either window or block should be provided"
      elsif !scopes.last.nil?
        raise Capybara::ScopeError, "`switch_to_window` is not supposed to be invoked from "\
                                    "`within` or `within_frame` blocks."
      end

      _switch_to_window(window, options, &window_locator)
    end

    ##
    # This method does the following:
    #
    # 1. Switches to the given window (it can be located by window instance/lambda/string).
    # 2. Executes the given block (within window located at previous step).
    # 3. Switches back (this step will be invoked even if exception will happen at second step)
    #
    # @overload within_window(window) { do_something }
    #   @param window [Capybara::Window]       instance of `Capybara::Window` class
    #     that will be switched to
    #   @raise [driver#no_such_window_error] if unexistent (e.g. closed) window was passed
    # @overload within_window(proc_or_lambda) { do_something }
    #   @param lambda [Proc]                  lambda. First window for which lambda
    #     returns a value other than false or nil will be switched to.
    #   @example
    #     within_window(->{ page.title == 'Page title' }) { click_button 'Submit' }
    #   @raise [Capybara::WindowError]         if no window matching lambda was found
    # @overload within_window(string) { do_something }
    #   @deprecated                            Pass window or lambda instead
    #   @param [String]                        handle, name, url or title of the window
    #
    # @raise [Capybara::ScopeError]        if this method is invoked inside `within_frame` method
    # @return                              value returned by the block
    #
    def within_window(window_or_handle)
      if window_or_handle.instance_of?(Capybara::Window)
        original = current_window
        scopes << nil
        begin
          _switch_to_window(window_or_handle) unless original == window_or_handle
          begin
            yield
          ensure
            _switch_to_window(original) unless original == window_or_handle
          end
        ensure
          scopes.pop
        end
      elsif window_or_handle.is_a?(Proc)
        original = current_window
        scopes << nil
        begin
          _switch_to_window { window_or_handle.call }
          begin
            yield
          ensure
            _switch_to_window(original)
          end
        ensure
          scopes.pop
        end
      else
        offending_line = caller.first
        file_line = offending_line.match(/^(.+?):(\d+)/)[0]
        warn "DEPRECATION WARNING: Passing string argument to #within_window is deprecated. "\
             "Pass window object or lambda. (called from #{file_line})"
        begin
          scopes << nil
          driver.within_window(window_or_handle) { yield }
        ensure
          scopes.pop
        end
      end
    end

    ##
    # Get the window that has been opened by the passed block.
    # It will wait for it to be opened (in the same way as other Capybara methods wait).
    # It's better to use this method than `windows.last`
    # {https://dvcs.w3.org/hg/webdriver/raw-file/default/webdriver-spec.html#h_note_10 as order of windows isn't defined in some drivers}
    #
    # @param options [Hash]
    # @option options [Numeric] :wait (Capybara.default_max_wait_time) maximum wait time
    # @return [Capybara::Window]       the window that has been opened within a block
    # @raise [Capybara::WindowError]   if block passed to window hasn't opened window
    #   or opened more than one window
    #
    def window_opened_by(options = {}, &block)
      old_handles = driver.window_handles
      block.call

      wait_time = Capybara::Queries::BaseQuery.wait(options, config.default_max_wait_time)
      document.synchronize(wait_time, errors: [Capybara::WindowError]) do
        opened_handles = (driver.window_handles - old_handles)
        if opened_handles.size != 1
          raise Capybara::WindowError, "block passed to #window_opened_by "\
                                       "opened #{opened_handles.size} windows instead of 1"
        end
        Window.new(self, opened_handles.first)
      end
    end

    ##
    #
    # Execute the given script, not returning a result. This is useful for scripts that return
    # complex objects, such as jQuery statements. +execute_script+ should be used over
    # +evaluate_script+ whenever possible.
    #
    # @param [String] script   A string of JavaScript to execute
    # @param args  Optional arguments that will be passed to the script.  Driver support for this is optional and types of objects supported may differ between drivers
    #
    def execute_script(script, *args)
      @touched = true
      if args.empty?
        driver.execute_script(script)
      else
        raise Capybara::NotSupportedByDriverError, "The current driver does not support execute_script arguments" if driver.method(:execute_script).arity == 1
        driver.execute_script(script, *args.map { |arg| arg.is_a?(Capybara::Node::Element) ?  arg.base : arg} )
      end
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
    def evaluate_script(script, *args)
      @touched = true
      result = if args.empty?
        driver.evaluate_script(script)
      else
        raise Capybara::NotSupportedByDriverError, "The current driver does not support evaluate_script arguments" if driver.method(:evaluate_script).arity == 1
        driver.evaluate_script(script, *args.map { |arg| arg.is_a?(Capybara::Node::Element) ?  arg.base : arg} )
      end
      element_script_result(result)
    end

    ##
    #
    # Execute the block, accepting a alert.
    #
    # @!macro modal_params
    #   Expects a block whose actions will trigger the display modal to appear
    #   @example
    #     $0 do
    #       click_link('link that triggers appearance of system modal')
    #     end
    #   @overload $0(text, options = {}, &blk)
    #     @param text [String, Regexp]  Text or regex to match against the text in the modal.  If not provided any modal is matched
    #     @option options [Numeric] :wait (Capybara.default_max_wait_time) Maximum time to wait for the modal to appear after executing the block.
    #     @yield Block whose actions will trigger the system modal
    #   @overload $0(options = {}, &blk)
    #     @option options [Numeric] :wait (Capybara.default_max_wait_time) Maximum time to wait for the modal to appear after executing the block.
    #     @yield Block whose actions will trigger the system modal
    #   @return [String]  the message shown in the modal
    #   @raise [Capybara::ModalNotFound]  if modal dialog hasn't been found
    #
    #
    def accept_alert(text_or_options=nil, options={}, &blk)
      accept_modal(:alert, text_or_options, options, &blk)
    end

    ##
    #
    # Execute the block, accepting a confirm.
    #
    # @macro modal_params
    #
    def accept_confirm(text_or_options=nil, options={}, &blk)
      accept_modal(:confirm, text_or_options, options, &blk)
    end

    ##
    #
    # Execute the block, dismissing a confirm.
    #
    # @macro modal_params
    #
    def dismiss_confirm(text_or_options=nil, options={}, &blk)
      dismiss_modal(:confirm, text_or_options, options, &blk)
    end

    ##
    #
    # Execute the block, accepting a prompt, optionally responding to the prompt.
    #
    # @macro modal_params
    # @option options [String] :with   Response to provide to the prompt
    #
    def accept_prompt(text_or_options=nil, options={}, &blk)
      accept_modal(:prompt, text_or_options, options, &blk)
    end

    ##
    #
    # Execute the block, dismissing a prompt.
    #
    # @macro modal_params
    #
    def dismiss_prompt(text_or_options=nil, options={}, &blk)
      dismiss_modal(:prompt, text_or_options, options, &blk)
    end

    ##
    #
    # Save a snapshot of the page. If `Capybara.asset_host` is set it will inject `base` tag
    #   pointing to `asset_host`.
    #
    # If invoked without arguments it will save file to `Capybara.save_path`
    #   and file will be given randomly generated filename. If invoked with a relative path
    #   the path will be relative to `Capybara.save_path`, which is different from
    #   the previous behavior with `Capybara.save_and_open_page_path` where the relative path was
    #   relative to Dir.pwd
    #
    # @param [String] path  the path to where it should be saved
    # @return [String]      the path to which the file was saved
    #
    def save_page(path = nil)
      path = prepare_path(path, 'html')
      File.write(path, Capybara::Helpers.inject_asset_host(body, config.asset_host), mode: 'wb')
      path
    end

    ##
    #
    # Save a snapshot of the page and open it in a browser for inspection.
    #
    # If invoked without arguments it will save file to `Capybara.save_path`
    #   and file will be given randomly generated filename. If invoked with a relative path
    #   the path will be relative to `Capybara.save_path`, which is different from
    #   the previous behavior with `Capybara.save_and_open_page_path` where the relative path was
    #   relative to Dir.pwd
    #
    # @param [String] path  the path to where it should be saved
    #
    def save_and_open_page(path = nil)
      path = save_page(path)
      open_file(path)
    end

    ##
    #
    # Save a screenshot of page.
    #
    # If invoked without arguments it will save file to `Capybara.save_path`
    #   and file will be given randomly generated filename. If invoked with a relative path
    #   the path will be relative to `Capybara.save_path`, which is different from
    #   the previous behavior with `Capybara.save_and_open_page_path` where the relative path was
    #   relative to Dir.pwd
    #
    # @param [String] path    the path to where it should be saved
    # @param [Hash] options   a customizable set of options
    # @return [String]        the path to which the file was saved
    def save_screenshot(path = nil, options = {})
      path = prepare_path(path, 'png')
      driver.save_screenshot(path, options)
      path
    end

    ##
    #
    # Save a screenshot of the page and open it for inspection.
    #
    # If invoked without arguments it will save file to `Capybara.save_path`
    #   and file will be given randomly generated filename. If invoked with a relative path
    #   the path will be relative to `Capybara.save_path`, which is different from
    #   the previous behavior with `Capybara.save_and_open_page_path` where the relative path was
    #   relative to Dir.pwd
    #
    # @param [String] path    the path to where it should be saved
    # @param [Hash] options   a customizable set of options
    #
    def save_and_open_screenshot(path = nil, options = {})
      path = save_screenshot(path, options)
      open_file(path)
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

    DOCUMENT_METHODS.each do |method|
      define_method method do |*args, &block|
        document.send(method, *args, &block)
      end
    end

    def inspect
      %(#<Capybara::Session>)
    end

    def current_scope
      scope = scopes.last
      scope = document if [nil, :frame].include? scope
      scope
    end

    ##
    #
    # Yield a block using a specific wait time
    #
    def using_wait_time(seconds)
      if Capybara.threadsafe
        begin
          previous_wait_time = config.default_max_wait_time
          config.default_max_wait_time = seconds
          yield
        ensure
          config.default_max_wait_time = previous_wait_time
        end
      else
        Capybara.using_wait_time(seconds) { yield }
      end
    end

    ##
    #
    #  Accepts a block to set the configuration options if Capybara.threadsafe == true. Note that some options only have an effect
    #  if set at initialization time, so look at the configuration block that can be passed to the initializer too
    #
    def configure
      raise "Session configuration is only supported when Capybara.threadsafe == true" unless Capybara.threadsafe
      yield config
    end

    def self.instance_created?
      @@instance_created
    end

    def config
      @config ||= if Capybara.threadsafe
        Capybara.session_options.dup
      else
        Capybara::ReadOnlySessionConfig.new(Capybara.session_options)
      end
    end
  private

    @@instance_created = false

    def accept_modal(type, text_or_options, options, &blk)
      driver.accept_modal(type, modal_options(text_or_options, options), &blk)
    end

    def dismiss_modal(type, text_or_options, options, &blk)
      driver.dismiss_modal(type, modal_options(text_or_options, options), &blk)
    end

    def modal_options(text_or_options, options)
      text_or_options, options = nil, text_or_options if text_or_options.is_a?(Hash)
      options[:text] ||= text_or_options unless text_or_options.nil?
      options[:wait] ||= config.default_max_wait_time
      options
    end


    def open_file(path)
      begin
        require "launchy"
        Launchy.open(path)
      rescue LoadError
        warn "File saved to #{path}."
        warn "Please install the launchy gem to open the file automatically."
      end
    end

    def prepare_path(path, extension)
      if config.save_path || config.save_and_open_page_path.nil?
        path = File.expand_path(path || default_fn(extension), config.save_path)
      else
        path = File.expand_path(default_fn(extension), config.save_and_open_page_path) if path.nil?
      end
      FileUtils.mkdir_p(File.dirname(path))
      path
    end

    def default_fn(extension)
      timestamp = Time.new.strftime("%Y%m%d%H%M%S")
      "capybara-#{timestamp}#{rand(10**10)}.#{extension}"
    end

    def scopes
      @scopes ||= [nil]
    end

    def element_script_result(arg)
      case arg
      when Array
        arg.map { |e| element_script_result(e) }
      when Hash
        arg.each { |k, v| arg[k] = element_script_result(v) }
      when Capybara::Driver::Node
        Capybara::Node::Element.new(self, arg, nil, nil)
      else
        arg
      end
    end

    def _find_frame(*args)
      within(document) do  # Previous 2.x versions ignored current scope when finding frames - consider changing in 3.0
        case args[0]
        when Capybara::Node::Element
          args[0]
        when String, Hash
          find(:frame, *args)
        when Symbol
          find(*args)
        when Integer
          idx = args[0]
          all(:frame, minimum: idx+1)[idx]
        else
          raise TypeError
        end
      end
    end

    def _switch_to_window(window = nil, options= {})
      options, window = window, nil if window.is_a? Hash

      raise Capybara::ScopeError, "Window cannot be switched inside a `within_frame` block" if scopes.include?(:frame)
      raise Capybara::ScopeError, "Window cannot be switch inside a `within` block" unless scopes.last.nil?

      if window
        driver.switch_to_window(window.handle)
        window
      else
        wait_time = Capybara::Queries::BaseQuery.wait(options, config.default_max_wait_time)
        document.synchronize(wait_time, errors: [Capybara::WindowError]) do
          original_window_handle = driver.current_window_handle
          begin
            driver.window_handles.each do |handle|
              driver.switch_to_window handle
              if yield
                return Window.new(self, handle)
              end
            end
          rescue => e
            driver.switch_to_window(original_window_handle)
            raise e
          else
            driver.switch_to_window(original_window_handle)
            raise Capybara::WindowError, "Could not find a window matching block/lambda"
          end
        end
      end
    end

  end
end
