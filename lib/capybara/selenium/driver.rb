require 'selenium-webdriver'

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
    @app = app
    @browser = nil
    @exit_status = nil
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def visit(path)
    browser.navigate.to(path)
  end

  def html
    browser.page_source
  end

  def current_url
    browser.current_url
  end

  def find(selector)
    browser.find_elements(:xpath, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
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
      begin @browser.manage.delete_all_cookies
      rescue Selenium::WebDriver::Error::UnhandledError
        # delete_all_cookies fails when we've previously gone
        # to about:blank, so we rescue this error and do nothing
        # instead.
      end
      @browser.navigate.to('about:blank')
    end
  end

  ##
  #
  # Webdriver supports frame name, id, index(zero-based) or {Capybara::Element} to find iframe
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
    old_window = browser.window_handle
    browser.switch_to.frame(frame_handle)
    yield
  ensure
    browser.switch_to.window old_window
  end

  def find_window( selector )
    original_handle = browser.window_handle
    browser.window_handles.each do |handle|
      browser.switch_to.window handle
      if( selector == browser.execute_script("return window.name") ||
          browser.title.include?(selector) ||
          browser.current_url.include?(selector) ||
          (selector == handle) )
        browser.switch_to.window original_handle
        return handle
      end
    end
    raise Capybara::ElementNotFound, "Could not find a window identified by #{selector}"
  end

  def within_window(selector, &blk)
    handle = find_window( selector )
    browser.switch_to.window(handle, &blk)
  end

  def quit
    @browser.quit
  rescue Errno::ECONNREFUSED
    # Browser must have already gone
  end

  def invalid_element_errors
    [Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnhandledError, Selenium::WebDriver::Error::ElementNotVisibleError]
  end
end
