module Capybara
  class Session

    attr_reader :app, :mode, :mode_options

    def initialize(mode, app)
      if mode.respond_to?(:has_key?)
        @mode = mode[:driver] 
        @mode_options = mode
      else
        @mode = mode
        @mode_options = {}
      end
      
      @app = app
    end
    
    def driver
      @driver ||= case mode
      when :rack_test
        Capybara::Driver::RackTest.new(app)
      when :selenium
        Capybara::Driver::Selenium.new(app)
      when :culerity, :celerity
        Capybara::Driver::Celerity.new(app, mode_options)
      else
        raise Capybara::DriverNotFoundError, "no driver called #{mode} was found"
      end
    end

    def visit(path)
      driver.visit(path)
    end

    def click(locator)
      link = wait_for(XPath.link(locator).button(locator))
      raise Capybara::ElementNotFound, "no link or button '#{locator}' found" unless link
      link.click
    end

    def click_link(locator)
      link = wait_for(XPath.link(locator))
      raise Capybara::ElementNotFound, "no link with title, id or text '#{locator}' found" unless link
      link.click
    end

    def click_button(locator)
      button = wait_for(XPath.button(locator))
      raise Capybara::ElementNotFound, "no button with value or id or text '#{locator}' found" unless button
      button.click
    end

    def drag(source_locator, target_locator)
      source = wait_for(source_locator)
      raise Capybara::ElementNotFound, "drag source '#{source_locator}' not found on page" unless source
      target = wait_for(target_locator)
      raise Capybara::ElementNotFound, "drag target '#{target_locator}' not found on page" unless target
      source.drag_to(target)
    end

    def fill_in(locator, options={})
      field = wait_for(XPath.fillable_field(locator))
      raise Capybara::ElementNotFound, "cannot fill in, no text field, text area or password field with id or label '#{locator}' found" unless field
      field.set(options[:with])
    end

    def choose(locator)
      field = wait_for(XPath.radio_button(locator))
      raise Capybara::ElementNotFound, "cannot choose field, no radio button with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def check(locator)
      field = wait_for(XPath.checkbox(locator))
      raise Capybara::ElementNotFound, "cannot check field, no checkbox with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def uncheck(locator)
      field = wait_for(XPath.checkbox(locator))
      raise Capybara::ElementNotFound, "cannot uncheck field, no checkbox with id or label '#{locator}' found" unless field
      field.set(false)
    end

    def select(value, options={})
      field = wait_for(XPath.select(options[:from]))
      raise Capybara::ElementNotFound, "cannot select option, no select box with id or label '#{options[:from]}' found" unless field
      field.select(value)
    end

    def attach_file(locator, path)
      field = wait_for(XPath.file_field(locator))
      raise Capybara::ElementNotFound, "cannot attach file, no file field with id or label '#{locator}' found" unless field
      field.set(path)
    end

    def body
      driver.body
    end

    def has_content?(content)
      has_xpath?(XPath.content(content).to_s)
    end

    def has_xpath?(path, options={})
      results = all(path)
      if options[:text]
        results = filter_by_text(results, options[:text])
      end
      if options[:count]
        results.size == options[:count]
      else
        results.size > 0
      end
    end

    def has_css?(path, options={})
      has_xpath?(css_to_xpath(path), options)
    end

    def within(kind, scope=nil)
      kind, scope = Capybara.default_selector, kind unless scope
      scope = css_to_xpath(scope) if kind == :css
      raise Capybara::ElementNotFound, "scope '#{scope}' not found on page" unless wait_for(scope)
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

    def all(locator)
      XPath.wrap(locator).scope(current_scope).paths.map do |path|
        driver.find(path)
      end.flatten
    end

    def find(locator)
      all(locator).first
    end
    
    def wait_for(locator)
      return find(locator) unless driver.wait?
      8.times do
        result = find(locator)
        return result if result
        sleep(0.1)
      end
      nil
    end

    def find_field(locator)
      find(XPath.field(locator))
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find(XPath.link(locator))
    end

    def find_button(locator)
      find(XPath.button(locator))
    end

    def evaluate_script(script)
      driver.evaluate_script(script)
    end

  private

    def css_to_xpath(css)
      Nokogiri::CSS.xpath_for(css).first
    end

    def filter_by_text(nodes, text)
      nodes.select do |node|
        case text
        when String
          node.text.include?(text)
        when Regexp
          node.text =~ text
        end
      end
    end

    def current_scope
      scopes.join('')
    end

    def scopes
      @scopes ||= []
    end
  end
end
