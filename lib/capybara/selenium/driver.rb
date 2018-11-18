# frozen_string_literal: true

require 'uri'
require 'English'

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
    warn "Warning: You're using an unsupported version of selenium-webdriver, please upgrade." if Gem.loaded_specs['selenium-webdriver'].version < Gem::Version.new('3.5.0')
  rescue LoadError => err
    raise err if err.message !~ /selenium-webdriver/

    raise LoadError, "Capybara's selenium driver is unable to load `selenium-webdriver`, please install the gem and add `gem 'selenium-webdriver'` to your Gemfile if you are using bundler."
  end

  def browser
    @browser ||= begin
      processed_options = options.reject { |key, _val| SPECIAL_OPTIONS.include?(key) }
      Selenium::WebDriver.for(options[:browser], processed_options).tap do |driver|
        specialize_driver(driver)
        setup_exit_handler
      end
    end
    @browser
  end

  def initialize(app, **options)
    self.class.load_selenium
    @app = app
    @browser = nil
    @exit_status = nil
    @frame_handles = Hash.new { |hash, handle| hash[handle] = [] }
    @options = DEFAULT_OPTIONS.merge(options)
    @node_class = ::Capybara::Selenium::Node
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
    browser.find_elements(:xpath, selector).map(&method(:build_node))
  end

  def find_css(selector)
    browser.find_elements(:css, selector).map(&method(:build_node))
  end

  def wait?; true; end
  def needs_server?; true; end

  def execute_script(script, *args)
    browser.execute_script(script, *native_args(args))
  end

  def evaluate_script(script, *args)
    result = execute_script("return #{script}", *args)
    unwrap_script_result(result)
  end

  def evaluate_async_script(script, *args)
    browser.manage.timeouts.script_timeout = Capybara.default_max_wait_time
    result = browser.execute_async_script(script, *native_args(args))
    unwrap_script_result(result)
  end

  def save_screenshot(path, **_options)
    browser.save_screenshot(path)
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    return unless @browser

    navigated = false
    timer = Capybara::Helpers.timer(expire_in: 10)
    begin
      # Only trigger a navigation if we haven't done it already, otherwise it
      # can trigger an endless series of unload modals
      reset_browser_state unless navigated
      navigated = true
      # Ensure the page is empty and trigger an UnhandledAlertError for any modals that appear during unload
      wait_for_empty_page(timer)
    rescue Selenium::WebDriver::Error::UnhandledAlertError, Selenium::WebDriver::Error::UnexpectedAlertOpenError
      # This error is thrown if an unhandled alert is on the page
      # Firefox appears to automatically dismiss this alert, chrome does not
      # We'll try to accept it
      accept_unhandled_reset_alert
      # try cleaning up the browser again
      retry
    end
  end

  def switch_to_frame(frame)
    handles = @frame_handles[current_window_handle]
    case frame
    when :top
      handles.clear
      browser.switch_to.default_content
    when :parent
      handles.pop
      browser.switch_to.parent_frame
    else
      handles << frame.native
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
      browser.manage.window.resize_to(width, height)
    end
  end

  def maximize_window(handle)
    within_given_window(handle) do
      browser.manage.window.maximize
    end
    sleep 0.1 # work around for https://code.google.com/p/selenium/issues/detail?id=7405
  end

  def fullscreen_window(handle)
    within_given_window(handle) do
      browser.manage.window.full_screen
    end
  end

  def close_window(handle)
    raise ArgumentError, 'Not allowed to close the primary window' if handle == window_handles.first

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
    @browser&.quit
  rescue Selenium::WebDriver::Error::SessionNotCreatedError, Errno::ECONNREFUSED # rubocop:disable Lint/HandleExceptions
    # Browser must have already gone
  rescue Selenium::WebDriver::Error::UnknownError => err
    unless silenced_unknown_error_message?(err.message) # Most likely already gone
      # probably already gone but not sure - so warn
      warn "Ignoring Selenium UnknownError during driver quit: #{err.message}"
    end
  ensure
    @browser = nil
  end

  def invalid_element_errors
    [
      ::Selenium::WebDriver::Error::StaleElementReferenceError,
      ::Selenium::WebDriver::Error::UnhandledError,
      ::Selenium::WebDriver::Error::ElementNotVisibleError,
      ::Selenium::WebDriver::Error::InvalidSelectorError, # Work around a chromedriver go_back/go_forward race condition
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

private

  def native_args(args)
    args.map { |arg| arg.is_a?(Capybara::Selenium::Node) ? arg.native : arg }
  end

  def clear_browser_state
    delete_all_cookies
    deprecated_clear_storage
  rescue Selenium::WebDriver::Error::UnhandledError # rubocop:disable Lint/HandleExceptions
    # delete_all_cookies fails when we've previously gone
    # to about:blank, so we rescue this error and do nothing
    # instead.
  end

  def delete_all_cookies
    @browser.manage.delete_all_cookies
  end

  def deprecated_clear_storage
    clear_session_storage if options[:clear_session_storage]
    clear_local_storage if options[:clear_local_storage]
  end

  def clear_session_storage
    if @browser.respond_to? :session_storage
      @browser.session_storage.clear
    else
      warn 'sessionStorage clear requested but is not available for this driver'
    end
  end

  def clear_local_storage
    if @browser.respond_to? :local_storage
      @browser.local_storage.clear
    else
      warn 'localStorage clear requested but is not available for this driver'
    end
  end

  def navigate_with_accept(url)
    @browser.navigate.to(url)
    sleep 0.1 # slight wait for alert
    @browser.switch_to.alert.accept
  rescue modal_error # rubocop:disable Lint/HandleExceptions
    # alert now gone, should mean navigation happened
  end

  def modal_error
    Selenium::WebDriver::Error::NoSuchAlertError
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

  def silenced_unknown_error_message?(msg)
    silenced_unknown_error_messages.any? { |regex| msg =~ regex }
  end

  def silenced_unknown_error_messages
    [/Error communicating with the remote browser/]
  end

  def unwrap_script_result(arg)
    case arg
    when Array
      arg.map { |arr| unwrap_script_result(arr) }
    when Hash
      arg.each { |key, value| arg[key] = unwrap_script_result(value) }
    when Selenium::WebDriver::Element
      build_node(arg)
    else
      arg
    end
  end

  def build_node(native_node)
    ::Capybara::Selenium::Node.new(self, native_node)
  end

  def specialize_driver(sel_driver)
    case sel_driver.browser
    when :chrome
      extend ChromeDriver
    when :firefox
      require 'capybara/selenium/patches/pause_duration_fix' if pause_broken?(sel_driver)
      extend MarionetteDriver if sel_driver.capabilities.is_a?(::Selenium::WebDriver::Remote::W3C::Capabilities)
    end
  end

  def pause_broken?(driver)
    driver.capabilities['moz:geckodriverVersion']&.start_with?('0.22.')
  end

  def setup_exit_handler
    main = Process.pid
    at_exit do
      # Store the exit status of the test run since it goes away after calling the at_exit proc...
      @exit_status = $ERROR_INFO.status if $ERROR_INFO.is_a?(SystemExit)
      quit if Process.pid == main
      exit @exit_status if @exit_status # Force exit with stored status
    end
  end

  def reset_browser_state
    clear_browser_state
    @browser.navigate.to('about:blank')
  end

  def wait_for_empty_page(timer)
    until find_xpath('/html/body/*').empty?
      raise Capybara::ExpectationNotMet, 'Timed out waiting for Selenium session reset' if timer.expired?

      sleep 0.05
    end
  end

  def accept_unhandled_reset_alert
    @browser.switch_to.alert.accept
    sleep 0.25 # allow time for the modal to be handled
  rescue modal_error
    # The alert is now gone.
    # If navigation has not occurred attempt again and accept alert
    # since FF may have dismissed the alert at first attempt.
    navigate_with_accept('about:blank') if current_url != 'about:blank'
  end
end

require 'capybara/selenium/driver_specializations/chrome_driver'
require 'capybara/selenium/driver_specializations/marionette_driver'
