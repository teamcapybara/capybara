module Capybara

  class << self
    attr_writer :default_selector

    def default_selector
      @default_selector ||= :xpath
    end
  end

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
      find_link(locator).click
    end

    def click_button(locator)
      find_button(locator).click
    end

    def fill_in(locator, options={})
      find_field(locator, :text_field, :text_area, :password_field).set(options[:with])
    end

    def choose(locator)
      find_field(locator, :radio).set(true)
    end

    def check(locator)
      find_field(locator, :checkbox).set(true)
    end

    def uncheck(locator)
      find_field(locator, :checkbox).set(false)
    end

    def select(value, options={})
      find_field(options[:from], :select).select(value)
    end

    def attach_file(locator, path)
      find_field(locator, :file_field).set(path)
    end

    def body
      driver.body
    end

    def has_content?(content)
      has_xpath?("//*[contains(.,'#{content}')]")
    end

    def has_xpath?(path, options={})
      results = find(path)
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
      raise Capybara::ElementNotFound, "scope '#{scope}' not found on page" if find(scope).empty?
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

    def find_field(locator, *kinds)
      kinds = FIELDS_PATHS.keys if kinds.empty?
      field = find_field_by_id(locator, *kinds) || find_field_by_label(locator, *kinds)
      raise Capybara::ElementNotFound, "no field of kind #{kinds.inspect} with id or label '#{locator}' found" unless field
      field
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      link = find("//a[@id='#{locator}' or contains(.,'#{locator}') or @title='#{locator}']").first
      raise Capybara::ElementNotFound, "no link with title, id or text '#{locator}' found" unless link
      link
    end

    def find_button(locator)
      button = find("//input[@type='submit' or @type='image'][@id='#{locator}' or @value='#{locator}']").first || find("//button[@id='#{locator}' or @value='#{locator}' or contains(.,'#{locator}')]").first
      raise Capybara::ElementNotFound, "no button with value or id '#{locator}' found" unless button
      button
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
      kinds.each do |kind|
        path = FIELDS_PATHS[kind]
        element = find(path.call(locator)).first
        return element if element
      end
      return nil
    end

    def find_field_by_label(locator, *kinds)
      kinds.each do |kind|
        label = find("//label[contains(.,'#{locator}')]").first
        if label
          element = find_field_by_id(label[:for], kind)
          return element if element
        end
      end
      return nil
    end

    def find(locator)
      locator = current_scope.to_s + locator
      driver.find(locator)
    end
  end
end
