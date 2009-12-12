module Capybara
  class Session

    FIELDS_PATHS = {
      :text_field => proc { |id| "//input[@type='text'][@id='#{id}']" },
      :text_area => proc { |id| "//textarea[@id='#{id}']" },
      :password_field => proc { |id| "//input[@type='password'][@id='#{id}']" },
      :radio => proc { |id| "//input[@type='radio'][@id='#{id}']" },
      :hidden_field => proc { |id| "//input[@type='hidden'][@id='#{id}']" },
      :checkbox => proc { |id| "//input[@type='checkbox'][@id='#{id}']" },
      :select => proc { |id| "//select[@id='#{id}']" },
      :file_field => proc { |id| "//input[@type='file'][@id='#{id}']" }
    }

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
      field = find_field(locator, :text_field, :text_area, :password_field)
      raise Capybara::ElementNotFound, "cannot fill in, no text field, text area or password field with id or label '#{locator}' found" unless field
      field.set(options[:with])
    end

    def choose(locator)
      field = find_field(locator, :radio)
      raise Capybara::ElementNotFound, "cannot choose field, no radio button with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def check(locator)
      field = find_field(locator, :checkbox)
      raise Capybara::ElementNotFound, "cannot check field, no checkbox with id or label '#{locator}' found" unless field
      field.set(true)
    end

    def uncheck(locator)
      field = find_field(locator, :checkbox)
      raise Capybara::ElementNotFound, "cannot uncheck field, no checkbox with id or label '#{locator}' found" unless field
      field.set(false)
    end

    def select(value, options={})
      field = find_field(options[:from], :select)
      raise Capybara::ElementNotFound, "cannot select option, no select box with id or label '#{options[:from]}' found" unless field
      field.select(value)
    end

    def attach_file(locator, path)
      field = find_field(locator, :file_field)
      raise Capybara::ElementNotFound, "cannot attach file, no file field with id or label '#{locator}' found" unless field
      field.set(path)
    end

    def body
      driver.body
    end

    def has_content?(content)
      has_xpath?("//*[contains(.,#{sanitized_xpath_string(content)})]")
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
      within "//fieldset[@id='#{locator}' or contains(legend,'#{locator}')]" do
        yield
      end
    end

    def within_table(locator)
      within "//table[@id='#{locator}' or contains(caption,'#{locator}')]" do
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

    def find_field(locator, *kinds)
      kinds = FIELDS_PATHS.keys if kinds.empty?
      find_field_by_id(locator, *kinds) || find_field_by_label(locator, *kinds)
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find("//a[@id='#{locator}' or contains(.,'#{locator}') or @title='#{locator}']")
    end

    def find_button(locator)
      button = find("//input[@type='submit' or @type='image'][@id='#{locator}' or @value='#{locator}']")
      button || find("//button[@id='#{locator}' or @value='#{locator}' or contains(.,'#{locator}')]")
    end

    def evaluate_script(script)
      begin
        driver.evaluate_script(script)
      rescue NoMethodError
        raise NotSupportedByDriverError
      end
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

    def find_field_by_id(locator, *kinds)
      field_locator = kinds.map { |kind| FIELDS_PATHS[kind].call(locator) }.join("|")
      element = find(field_locator)
      return element
    end

    def find_field_by_label(locator, *kinds)
      label = find("//label[text()='#{locator}']") || find("//label[contains(.,'#{locator}')]")
      if label
        element = find_field_by_id(label[:for], *kinds)
        return element if element
      end
      return nil
    end

    def sanitized_xpath_string(string)
      if string.include?("'")
        string = string.split("'", -1).map do |substr|
          "'#{substr}'"
        end.join(%q{,"'",})
        "concat(#{string})"
      else
        "'#{string}'"
      end
    end

    def sanitized_xpath_string(string)
      if string.include?("'")
        string = string.split("'", -1).map do |substr|
          "'#{substr}'"
        end.join(%q{,"'",})
        "concat(#{string})"
      else
        "'#{string}'"
      end
    end
  end
end
