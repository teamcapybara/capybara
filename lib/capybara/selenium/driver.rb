# frozen_string_literal: true

require "uri"
require "English"

class Capybara::Selenium::Driver < Capybara::Driver::Base
  DEFAULT_OPTIONS = {
    browser: :firefox,
    clear_local_storage: false,
    clear_session_storage: false
  }.freeze
  SPECIAL_OPTIONS = %i[browser clear_local_storage clear_session_storage].freeze

  attr_reader :app, :options

  def self.load_selenium
    require 'selenium-webdriver'
    # Fix for selenium-webdriver 3.4.0 which misnamed these
    unless defined?(::Selenium::WebDriver::Error::ElementNotInteractableError)
      ::Selenium::WebDriver::Error.const_set('ElementNotInteractableError', Class.new(::Selenium::WebDriver::Error::WebDriverError))
    end
    unless defined?(::Selenium::WebDriver::Error::ElementClickInterceptedError)
      ::Selenium::WebDriver::Error.const_set('ElementClickInterceptedError', Class.new(::Selenium::WebDriver::Error::WebDriverError))
    end
  rescue LoadError => e
    if e.message =~ /selenium-webdriver/
      raise LoadError, "Capybara's selenium driver is unable to load `selenium-webdriver`, please install the gem and add `gem 'selenium-webdriver'` to your Gemfile if you are using bundler."
    else
      raise e
    end
  end

  def browser
    unless @browser
      if firefox?
        options[:desired_capabilities] ||= {}
        options[:desired_capabilities][:unexpectedAlertBehaviour] = "ignore"
      end

      @processed_options = options.reject { |key, _val| SPECIAL_OPTIONS.include?(key) }
      @browser = Selenium::WebDriver.for(options[:browser], @processed_options)

      @w3c = ((defined?(Selenium::WebDriver::Remote::W3CCapabilities) && @browser.capabilities.is_a?(Selenium::WebDriver::Remote::W3CCapabilities)) ||
              (defined?(Selenium::WebDriver::Remote::W3C::Capabilities) && @browser.capabilities.is_a?(Selenium::WebDriver::Remote::W3C::Capabilities)))
      main = Process.pid

      at_exit do
        # Store the exit status of the test run since it goes away after calling the at_exit proc...
        @exit_status = $ERROR_INFO.status if $ERROR_INFO.is_a?(SystemExit)
        quit if Process.pid == main
        exit @exit_status if @exit_status # Force exit with stored status
      end
    end
    @browser
  end

  def initialize(app, **options)
    self.class.load_selenium
    @session = nil
    @app = app
    @browser = nil
    @exit_status = nil
    @frame_handles = {}
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def visit(path)
    browser.navigate.to(path)
  end

  def refresh
    browser.navigate.refresh
  end

  def go_back
    browser.navigate.back
  end

  def go_forward
    browser.navigate.forward
  end

  def html
    browser.page_source
  end

  def title
    browser.title
  end

  def current_url
    browser.current_url
  end

  def find_xpath(selector)
    browser.find_elements(:xpath, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
  end

  def find_css(selector)
    browser.find_elements(:css, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
  end

  def wait?; true; end
  def needs_server?; true; end

  def execute_script(script, *args)
    browser.execute_script(script, *args.map { |arg| arg.is_a?(Capybara::Selenium::Node) ? arg.native : arg })
  end

  def evaluate_script(script, *args)
    result = execute_script("return #{script}", *args)
    unwrap_script_result(result)
  end

  def evaluate_async_script(script, *args)
    browser.manage.timeouts.script_timeout = Capybara.default_max_wait_time
    result = browser.execute_async_script(script, *args.map { |arg| arg.is_a?(Capybara::Selenium::Node) ? arg.native : arg })
    unwrap_script_result(result)
  end

  def save_screenshot(path, **_options)
    browser.save_screenshot(path)
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    return unless @browser

    if firefox? || chrome?
      switch_to_window(window_handles.first)
      window_handles.slice(1..-1).each { |win| close_window(win) }
    end

    navigated = false
    start_time = Capybara::Helpers.monotonic_time
    begin
      unless navigated
        # Only trigger a navigation if we haven't done it already, otherwise it
        # can trigger an endless series of unload modals
        begin
          @browser.manage.delete_all_cookies
          clear_storage
        rescue Selenium::WebDriver::Error::UnhandledError
          # delete_all_cookies fails when we've previously gone
          # to about:blank, so we rescue this error and do nothing
          # instead.
        end
        @browser.navigate.to("about:blank")
      end
      navigated = true

      # Ensure the page is empty and trigger an UnhandledAlertError for any modals that appear during unload
      until find_xpath("/html/body/*").empty?
        raise Capybara::ExpectationNotMet, 'Timed out waiting for Selenium session reset' if (Capybara::Helpers.monotonic_time - start_time) >= 10
        sleep 0.05
      end
    rescue Selenium::WebDriver::Error::UnhandledAlertError, Selenium::WebDriver::Error::UnexpectedAlertOpenError
      # This error is thrown if an unhandled alert is on the page
      # Firefox appears to automatically dismiss this alert, chrome does not
      # We'll try to accept it
      begin
        @browser.switch_to.alert.accept
        sleep 0.25 # allow time for the modal to be handled
      rescue modal_error
        # The alert is now gone
        if current_url != "about:blank"
          begin
            # If navigation has not occurred attempt again and accept alert
            # since FF may have dismissed the alert at first attempt
            @browser.navigate.to("about:blank")
            sleep 0.1 # slight wait for alert
            @browser.switch_to.alert.accept
          rescue modal_error # rubocop:disable Metrics/BlockNesting
            # alert now gone, should mean navigation happened
          end
        end
      end
      # try cleaning up the browser again
      retry
    end
  end

  def switch_to_frame(frame)
    case frame
    when :top
      @frame_handles[browser.window_handle] = []
      browser.switch_to.default_content
    when :parent
      # would love to use browser.switch_to.parent_frame here
      # but it has an issue if the current frame is removed from within it
      @frame_handles[browser.window_handle].pop
      browser.switch_to.default_content
      @frame_handles[browser.window_handle].each { |fh| browser.switch_to.frame(fh) }
    else
      @frame_handles[browser.window_handle] ||= []
      @frame_handles[browser.window_handle] << frame.native
      browser.switch_to.frame(frame.native)
    end
  end

  def current_window_handle
    browser.window_handle
  end

  def window_size(handle)
    within_given_window(handle) do
      size = browser.manage.window.size
      [size.width, size.height]
    end
  end

  def resize_window_to(handle, width, height)
    within_given_window(handle) do
      # Don't set the size if already set - See https://github.com/mozilla/geckodriver/issues/643
      if marionette? && (window_size(handle) == [width, height])
        {}
      else
        browser.manage.window.resize_to(width, height)
      end
    end
  end

  def maximize_window(handle)
    within_given_window(handle) do
      browser.manage.window.maximize
    end
    sleep 0.1 # work around for https://code.google.com/p/selenium/issues/detail?id=7405
  end

  def close_window(handle)
    raise ArgumentError, "Not allowed to close the primary window" if handle == window_handles.first
    within_given_window(handle) do
      browser.close
    end
  end

  def window_handles
    browser.window_handles
  end

  def open_new_window
    browser.execute_script('window.open();')
  end

  def switch_to_window(handle)
    browser.switch_to.window handle
  end

  def accept_modal(_type, **options)
    yield if block_given?
    modal = find_modal(options)

    modal.send_keys options[:with] if options[:with]

    message = modal.text
    modal.accept
    message
  end

  def dismiss_modal(_type, **options)
    yield if block_given?
    modal = find_modal(options)
    message = modal.text
    modal.dismiss
    message
  end

  def quit
    @browser.quit if @browser
  rescue Selenium::WebDriver::Error::SessionNotCreatedError, Errno::ECONNREFUSED
    # Browser must have already gone
  rescue Selenium::WebDriver::Error::UnknownError => e
    unless silenced_unknown_error_message?(e.message) # Most likely already gone
      # probably already gone but not sure - so warn
      warn "Ignoring Selenium UnknownError during driver quit: #{e.message}"
    end
  ensure
    @browser = nil
  end

  def invalid_element_errors
    [
      ::Selenium::WebDriver::Error::StaleElementReferenceError,
      ::Selenium::WebDriver::Error::UnhandledError,
      ::Selenium::WebDriver::Error::ElementNotVisibleError,
      ::Selenium::WebDriver::Error::InvalidSelectorError, # Work around a race condition that can occur with chromedriver and #go_back/#go_forward
      ::Selenium::WebDriver::Error::ElementNotInteractableError,
      ::Selenium::WebDriver::Error::ElementClickInterceptedError,
      ::Selenium::WebDriver::Error::InvalidElementStateError,
      ::Selenium::WebDriver::Error::ElementNotSelectableError,
      ::Selenium::WebDriver::Error::ElementNotSelectableError,
      ::Selenium::WebDriver::Error::NoSuchElementError, # IE
      ::Selenium::WebDriver::Error::InvalidArgumentError # IE
    ]
  end

  def no_such_window_error
    Selenium::WebDriver::Error::NoSuchWindowError
  end

  # @api private
  def marionette?
    firefox? && browser && @w3c
  end

  # @api private
  def firefox?
    browser_name == "firefox"
  end

  # @api private
  def chrome?
    browser_name == "chrome"
  end

  # @api private
  def edge?
    browser_name == "edge"
  end

  # @api private
  def ie?
    browser_name == "ie"
  end

private

  def browser_name
    options[:browser].to_s
  end

  def clear_storage
    if options[:clear_session_storage]
      if @browser.respond_to? :session_storage
        @browser.session_storage.clear
      else
        warn "sessionStorage clear requested but is not available for this driver"
      end
    end
    if options[:clear_local_storage]
      if @browser.respond_to? :local_storage
        @browser.local_storage.clear
      else
        warn "localStorage clear requested but is not available for this driver"
      end
    end
  end

  def modal_error
    if defined?(Selenium::WebDriver::Error::NoSuchAlertError)
      Selenium::WebDriver::Error::NoSuchAlertError
    else
      Selenium::WebDriver::Error::NoAlertPresentError
    end
  end

  def insert_modal_handlers(accept, response_text)
    prompt_response = if accept
      if response_text.nil?
        "default_text"
      else
        "'#{response_text.gsub("\\", "\\\\\\").gsub("'", "\\\\'")}'"
      end
    else
      'null'
    end

    script = <<-JS
      if (typeof window.capybara  === 'undefined') {
        window.capybara = {
          modal_handlers: [],
          current_modal_status: function() {
            return [this.modal_handlers[0].called, this.modal_handlers[0].modal_text];
          },
          add_handler: function(handler) {
            this.modal_handlers.unshift(handler);
          },
          remove_handler: function(handler) {
            window.alert = handler.alert;
            window.confirm = handler.confirm;
            window.prompt = handler.prompt;
          },
          handler_called: function(handler, str) {
            handler.called = true;
            handler.modal_text = str;
            this.remove_handler(handler);
          }
        };
      };

      var modal_handler = {
        prompt: window.prompt,
        confirm: window.confirm,
        alert: window.alert,
        called: false
      }
      window.capybara.add_handler(modal_handler);

      window.alert = window.confirm = function(str = "") {
        window.capybara.handler_called(modal_handler, str.toString());
        return #{accept ? 'true' : 'false'};
      }
      window.prompt = function(str = "", default_text = "") {
        window.capybara.handler_called(modal_handler, str.toString());
        return #{prompt_response};
      }
    JS
    execute_script script
  end

  def within_given_window(handle)
    original_handle = current_window_handle
    if handle == original_handle
      yield
    else
      switch_to_window(handle)
      result = yield
      switch_to_window(original_handle)
      result
    end
  end

  def find_modal(text: nil, **options)
    # Selenium has its own built in wait (2 seconds)for a modal to show up, so this wait is really the minimum time
    # Actual wait time may be longer than specified
    wait = Selenium::WebDriver::Wait.new(
      timeout: options.fetch(:wait, session_options.default_max_wait_time) || 0,
      ignore: modal_error
    )
    begin
      wait.until do
        alert = @browser.switch_to.alert
        regexp = text.is_a?(Regexp) ? text : Regexp.escape(text.to_s)
        alert.text.match(regexp) ? alert : nil
      end
    rescue Selenium::WebDriver::Error::TimeOutError
      raise Capybara::ModalNotFound, "Unable to find modal dialog#{" with #{text}" if text}"
    end
  end

  def find_headless_modal(text: nil, **options)
    # Selenium has its own built in wait (2 seconds)for a modal to show up, so this wait is really the minimum time
    # Actual wait time may be longer than specified
    wait = Selenium::WebDriver::Wait.new(
      timeout: options.fetch(:wait, session_options.default_max_wait_time) || 0,
      ignore: modal_error
    )
    begin
      wait.until do
        called, alert_text = evaluate_script('window.capybara && window.capybara.current_modal_status()')
        if called
          execute_script('window.capybara && window.capybara.modal_handlers.shift()')
          regexp = text.is_a?(Regexp) ? text : Regexp.escape(text.to_s)
          if alert_text.match(regexp)
            alert_text
          else
            raise Capybara::ModalNotFound, "Unable to find modal dialog#{" with #{text}" if text}"
          end
        elsif called.nil?
          # page changed so modal_handler data has gone away
          warn "Can't verify modal text when page change occurs - ignoring" if options[:text]
          ""
        else
          nil
        end
      end
    rescue Selenium::WebDriver::Error::TimeOutError
      raise Capybara::ModalNotFound, "Unable to find modal dialog#{" with #{options[:text]}" if options[:text]}"
    end
  end

  def silenced_unknown_error_message?(msg)
    silenced_unknown_error_messages.any? { |r| msg =~ r }
  end

  def silenced_unknown_error_messages
    [/Error communicating with the remote browser/]
  end

  def unwrap_script_result(arg)
    case arg
    when Array
      arg.map { |e| unwrap_script_result(e) }
    when Hash
      arg.each { |k, v| arg[k] = unwrap_script_result(v) }
    when Selenium::WebDriver::Element
      Capybara::Selenium::Node.new(self, arg)
    else
      arg
    end
  end
end
