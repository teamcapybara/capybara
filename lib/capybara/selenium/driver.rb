require 'selenium-webdriver'

class Capybara::Selenium::Driver < Capybara::Driver::Base
  DEFAULT_OPTIONS = {
    :resynchronize => false,
    :resynchronization_timeout => 10,
    :browser => :firefox
  }
  SPECIAL_OPTIONS = [:browser, :resynchronize, :resynchronization_timeout]

  attr_reader :app, :rack_server, :options

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
    @options = DEFAULT_OPTIONS.merge(options)
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    browser.navigate.to(url(path))
  end

  def source
    browser.page_source
  end

  def body
    browser.page_source
  end

  def current_url
    browser.current_url
  end

  def find(selector)
    browser.find_elements(:xpath, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
  end

  def wait?; true; end

  def resynchronize
    if options[:resynchronize]
      load_wait_for_ajax_support
      yield
      Capybara.timeout(options[:resynchronization_timeout], self, "failed to resynchronize, ajax request timed out") do
        evaluate_script("!window.capybaraRequestsOutstanding")
      end
    else
      yield
    end
  end

  def execute_script(script)
    browser.execute_script script
  end

  def evaluate_script(script)
    browser.execute_script "return #{script}"
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    if @browser
      begin
        @browser.manage.delete_all_cookies
      rescue Selenium::WebDriver::Error::UnhandledError => e
        # delete_all_cookies fails when we've previously gone
        # to about:blank, so we rescue this error and do nothing
        # instead.
      end
      @browser.navigate.to('about:blank')
    end
  end

  def within_frame(frame_id)
    old_window = browser.window_handle
    browser.switch_to.frame(frame_id)
    yield
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
    [Selenium::WebDriver::Error::ObsoleteElementError]
  end

private

  def load_wait_for_ajax_support
    browser.execute_script <<-JS
      window.capybaraRequestsOutstanding = 0;
      (function() { // Overriding XMLHttpRequest
          var oldXHR = window.XMLHttpRequest;

          function newXHR() {
              var realXHR = new oldXHR();

              window.capybaraRequestsOutstanding++;
              realXHR.addEventListener("readystatechange", function() {
                  if( realXHR.readyState == 4 ) {
                    setTimeout( function() {
                      window.capybaraRequestsOutstanding--;
                      if(window.capybaraRequestsOutstanding < 0) {
                        window.capybaraRequestsOutstanding = 0;
                      }
                    }, 500 );
                  }
              }, false);

              return realXHR;
          }

          window.XMLHttpRequest = newXHR;
      })();
    JS
  end

  def url(path)
    rack_server.url(path)
  end

end
