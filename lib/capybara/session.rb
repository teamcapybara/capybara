require 'capybara/wait_until'

module Capybara
  class Session
    include Searchable
    
    attr_reader :mode, :app

    def initialize(mode, app)
      @mode = mode
      @app = app
    end
    
    def driver
      
      @driver ||= case mode
      when :rack_test
        Capybara::Driver::RackTest.new(app)
      when :selenium
        Capybara::Driver::Selenium.new(app)
      when :celerity
        Capybara::Driver::Celerity.new(app)
      when :culerity
        Capybara::Driver::Culerity.new(app)
      else
        raise Capybara::DriverNotFoundError, "no driver called #{mode} was found"
      end
    end

    def current_url
      driver.current_url
    end
    
    def response_headers
      driver.response_headers
    end
    
    def visit(path)
      driver.visit(path)
    end

    def click(locator)
      msg = "no link or button '#{locator}' found"
      locate(XPath.link(locator).button(locator), msg).click
    end

    def click_link(locator)
      msg = "no link with title, id or text '#{locator}' found"
      locate(XPath.link(locator), msg).click
    end

    def click_button(locator)
      msg = "no button with value or id or text '#{locator}' found"
      locate(XPath.button(locator)).click
    end

    def drag(source_locator, target_locator)
      source = locate(source_locator, "drag source '#{source_locator}' not found on page")
      
      target = locate(target_locator, "drag target '#{target_locator}' not found on page")
      
      source.drag_to(target)
    end

    def fill_in(locator, options={})
      msg = "cannot fill in, no text field, text area or password field with id or label '#{locator}' found"
      locate(XPath.fillable_field(locator), msg).set(options[:with])
    end

    def choose(locator)
      msg = "cannot choose field, no radio button with id or label '#{locator}' found"
      locate(XPath.radio_button(locator), msg).set(true)
    end

    def check(locator)
      msg = "cannot check field, no checkbox with id or label '#{locator}' found"
      locate(XPath.checkbox(locator), msg).set(true)
    end

    def uncheck(locator)
      msg = "cannot uncheck field, no checkbox with id or label '#{locator}' found"
      locate(XPath.checkbox(locator), msg).set(false)
    end

    def select(value, options={})
      msg = "cannot select option, no select box with id or label '#{options[:from]}' found"
      locate(XPath.select(options[:from])).select(value)
    end

    def attach_file(locator, path)
      msg = "cannot attach file, no file field with id or label '#{locator}' found"
      locate(XPath.file_field(locator)).set(path)
    end

    def body
      driver.body
    end

    def within(kind, scope=nil)
      kind, scope = Capybara.default_selector, kind unless scope
      scope = XPath.from_css(scope) if kind == :css
      locate(scope, "scope '#{scope}' not found on page")
      scopes.push(scope)
      yield
      scopes.pop
    end

    def within_fieldset(locator)
      within XPath.fieldset(locator) do
        yield
      end
    end

    def within_table(locator)
      within XPath.table(locator) do
        yield
      end
    end

    def save_and_open_page
      require 'capybara/save_and_open_page'
      Capybara::SaveAndOpenPage.save_and_open_page(body)
    end

    #return node identified by locator or raise ElementNotFound(using desc)
    def locate(locator, fail_msg = nil)
      
      fail_msg ||= "Unable to locate '#{locator}'"
       
      node = nil
      begin
        if driver.wait?
          node = wait_until { find(locator) }
        else
          node = find(locator)
        end
      rescue Capybara::TimeoutError; end
          
      raise Capybara::ElementNotFound, fail_msg unless node
      
      node
    end
  
    def wait_until(timeout = Capybara.default_wait_time)
      WaitUntil.timeout(timeout) { yield }
    end
  
    def evaluate_script(script)
      driver.evaluate_script(script)
    end

  private

    def all_unfiltered(locator)
      XPath.wrap(locator).scope(current_scope).paths.map do |path|
        driver.find(path)
      end.flatten
    end
    
    def current_scope
      scopes.join('')
    end

    def scopes
      @scopes ||= []
    end
  end
end
