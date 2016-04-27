# frozen_string_literal: true
require "uri"

class Capybara::Selenium::Driver < Capybara::Driver::Base
  DEFAULT_OPTIONS = {
    :browser => :firefox
  }
  SPECIAL_OPTIONS = [:browser]

  attr_reader :app, :options

  def browser
    unless @browser
      @browser = Selenium::WebDriver.for(options[:browser], options.reject { |key,val| SPECIAL_OPTIONS.include?(key) })

      main = Process.pid
      at_exit do
        # Store the exit status of the test run since it goes away after calling the at_exit proc...
        @exit_status = $!.status if $!.is_a?(SystemExit)
        quit if Process.pid == main
        exit @exit_status if @exit_status # Force exit with stored status
      end
    end
    @browser
  end

  def initialize(app, options={})
    begin
      require 'selenium-webdriver'
    rescue LoadError => e
      if e.message =~ /selenium-webdriver/
        raise LoadError, "Capybara's selenium driver is unable to load `selenium-webdriver`, please install the gem and add `gem 'selenium-webdriver'` to your Gemfile if you are using bundler."
      else
        raise e
      end
    end

    @app = app
    @browser = nil
    @exit_status = nil
    @frame_handles = {}
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def visit(path)
    browser.navigate.to(path)
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

  def execute_script(script)
    browser.execute_script script
  end

  def evaluate_script(script)
    browser.execute_script "return #{script}"
  end

  def save_screenshot(path, options={})
    browser.save_screenshot(path)
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    if @browser
      navigated = false
      start_time = Capybara::Helpers.monotonic_time
      begin
        if !navigated
          # Only trigger a navigation if we haven't done it already, otherwise it
          # can trigger an endless series of unload modals
          begin
            @browser.manage.delete_all_cookies
          rescue Selenium::WebDriver::Error::UnhandledError
            # delete_all_cookies fails when we've previously gone
            # to about:blank, so we rescue this error and do nothing
            # instead.
          end
          @browser.navigate.to("about:blank")
        end
        navigated = true

        #Ensure the page is empty and trigger an UnhandledAlertError for any modals that appear during unload
        until find_xpath("/html/body/*").empty? do
          raise Capybara::ExpectationNotMet.new('Timed out waiting for Selenium session reset') if (Capybara::Helpers.monotonic_time - start_time) >= 10
          sleep 0.05
        end
      rescue Selenium::WebDriver::Error::UnhandledAlertError
        # This error is thrown if an unhandled alert is on the page
        # Firefox appears to automatically dismiss this alert, chrome does not
        # We'll try to accept it
        begin
          @browser.switch_to.alert.accept
          sleep 0.25 # allow time for the modal to be handled
        rescue Selenium::WebDriver::Error::NoAlertPresentError
          # The alert is now gone - nothing to do
        end
        # try cleaning up the browser again
        retry
      end
    end
  end

  ##
  #
  # Webdriver supports frame name, id, index(zero-based) or {Capybara::Node::Element} to find iframe
  #
  # @overload within_frame(index)
  #   @param [Integer] index                 index of a frame
  # @overload within_frame(name_or_id)
  #   @param [String] name_or_id             name or id of a frame
  # @overload within_frame(element)
  #   @param [Capybara::Node::Base] a_node   frame element
  #
  def within_frame(frame_handle)
    frame_handle = frame_handle.native if frame_handle.is_a?(Capybara::Node::Base)
    @frame_handles[browser.window_handle] ||= []
    @frame_handles[browser.window_handle] << frame_handle
    browser.switch_to.frame(frame_handle)
    yield
  ensure
    # would love to use browser.switch_to.parent_frame here
    # but it has an issue if the current frame is removed from within it
    @frame_handles[browser.window_handle].pop
    browser.switch_to.default_content
    @frame_handles[browser.window_handle].each { |fh| browser.switch_to.frame(fh) }
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

  def close_window(handle)
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

  # @api private
  def find_window(locator)
    handles = browser.window_handles
    return locator if handles.include? locator

    original_handle = browser.window_handle
    handles.each do |handle|
      switch_to_window(handle)
      if (locator == browser.execute_script("return window.name") ||
          browser.title.include?(locator) ||
          browser.current_url.include?(locator))
        switch_to_window(original_handle)
        return handle
      end
    end
    raise Capybara::ElementNotFound, "Could not find a window identified by #{locator}"
  end

  def within_window(locator)
    handle = find_window(locator)
    browser.switch_to.window(handle) { yield }
  end

  def accept_modal(type, options={}, &blk)
    yield if block_given?
    modal = find_modal(options)
    modal.send_keys options[:with] if options[:with]
    message = modal.text
    modal.accept
    message
  end

  def dismiss_modal(type, options={}, &blk)
    yield if block_given?
    modal = find_modal(options)
    message = modal.text
    modal.dismiss
    message
  end

  def quit
    @browser.quit if @browser
  rescue Errno::ECONNREFUSED
    # Browser must have already gone
  ensure
    @browser = nil
  end

  def invalid_element_errors
    [Selenium::WebDriver::Error::StaleElementReferenceError,
     Selenium::WebDriver::Error::UnhandledError,
     Selenium::WebDriver::Error::ElementNotVisibleError,
     Selenium::WebDriver::Error::InvalidSelectorError]  # Work around a race condition that can occur with chromedriver and #go_back/#go_forward
  end

  def no_such_window_error
    Selenium::WebDriver::Error::NoSuchWindowError
  end

  # @deprecated This method is being removed
  def browser_initialized?
    super && !@browser.nil?
  end

  private

  def within_given_window(handle)
    original_handle = self.current_window_handle
    if handle == original_handle
      yield
    else
      switch_to_window(handle)
      result = yield
      switch_to_window(original_handle)
      result
    end
  end

  def find_modal(options={})
    # Selenium has its own built in wait (2 seconds)for a modal to show up, so this wait is really the minimum time
    # Actual wait time may be longer than specified
    wait = Selenium::WebDriver::Wait.new(
      timeout: (options[:wait] || Capybara.default_max_wait_time),
      ignore: Selenium::WebDriver::Error::NoAlertPresentError)
    begin
      wait.until do
        alert = @browser.switch_to.alert
        regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text].to_s)
        alert.text.match(regexp) ? alert : nil
      end
    rescue Selenium::WebDriver::Error::TimeOutError
      raise Capybara::ModalNotFound.new("Unable to find modal dialog#{" with #{options[:text]}" if options[:text]}")
    end
  end

end
