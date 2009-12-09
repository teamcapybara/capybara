module Capybara
  class Session

    attr_reader :mode, :app

    def initialize(mode, app)
      @mode = mode
      @app = app
    end

    def driver
      @driver ||= case mode
      when :rack_test
        Capybara::Driver::RackTest.new(app)
      when :culerity
        Capybara::Driver::Culerity.new(app)
      when :selenium
        Capybara::Driver::Selenium.new(app)
      else
        raise Capybara::DriverNotFoundError, "no driver called #{mode} was found"
      end
    end

    def visit(path)
      driver.visit(path)
    end

    def click_link(locator)
      link = find_link(locator)
      raise Capybara::ElementNotFound, "no link with title, id or text '#{locator}' found" unless link
      link.click
    end

    def click_button(locator)
      button = find_button(locator)
      raise Capybara::ElementNotFound, "no button with value or id or text '#{locator}' found" unless button
      button.click
    end

    def fill_in(locator, options={})
      field = find(XPath.fillable_field(locator).to_s)
      raise Capybara::ElementNotFound, "cannot fill in, no text field, text area or password field with id or label '#{locator}' found" unless field
      field.set(options[:with])
    end

    def choose(locator)
      field = find(XPath.radio_button(locator).to_s)
      raise Capybara::ElementNotFound, "cannot choose field, no radio button with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def check(locator)
      field = find(XPath.checkbox(locator).to_s)
      raise Capybara::ElementNotFound, "cannot check field, no checkbox with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def uncheck(locator)
      field = find(XPath.checkbox(locator).to_s)
      raise Capybara::ElementNotFound, "cannot uncheck field, no checkbox with id or label '#{locator}' found" unless field
      field.set(false)
    end

    def select(value, options={})
      field = find(XPath.select(options[:from]).to_s)
      raise Capybara::ElementNotFound, "cannot select option, no select box with id or label '#{options[:from]}' found" unless field
      field.select(value)
    end

    def attach_file(locator, path)
      field = find(XPath.file_field(locator).to_s)
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
      raise Capybara::ElementNotFound, "scope '#{scope}' not found on page" unless find(scope)
      scopes.push(scope)
      yield
      scopes.pop
    end

    def within_fieldset(locator)
      within XPath.fieldset(locator).to_s do
        yield
      end
    end

    def within_table(locator)
      within XPath.table(locator).to_s do
        yield
      end
    end

    def save_and_open_page
      require 'capybara/save_and_open_page'
      Capybara::SaveAndOpenPage.save_and_open_page(body)
    end

    def all(locator)
      locator = current_scope.to_s + locator
      driver.find(locator)
    end
    
    def find(locator)
      all(locator).first
    end

    def find_field(locator)
      find(XPath.field(locator).to_s)
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find("//a[@id='#{locator}' or contains(.,'#{locator}') or @title='#{locator}']")
    end

    def find_button(locator)
      button = find("//input[@type='submit' or @type='image'][@id='#{locator}' or @value='#{locator}']")
      button || find("//button[@id='#{locator}' or @value='#{locator}' or contains(.,'#{locator}')]")
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
