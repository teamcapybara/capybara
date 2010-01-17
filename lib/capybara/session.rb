require 'capybara/wait_until'

module Capybara
  class Session
    include Searchable

    DSL_METHODS = [
      :all, :attach_file, :body, :check, :choose, :click, :click_button, :click_link, :current_url, :drag, :evaluate_script,
      :field_labeled, :fill_in, :find, :find_button, :find_by_id, :find_field, :find_link, :has_content?, :has_css?,
      :has_no_content?, :has_no_css?, :has_no_xpath?, :has_xpath?, :locate, :save_and_open_page, :select, :source, :uncheck,
      :visit, :wait_until, :within, :within_fieldset, :within_table
    ]

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
      locate(:xpath, XPath.link(locator).button(locator), msg).click
    end

    def click_link(locator)
      msg = "no link with title, id or containing text / image with alternative text like '#{locator}' found"
      locate(:xpath, XPath.link(locator), msg).click
    end

    def click_button(locator)
      msg = "no button with value or id or text '#{locator}' found"
      locate(:xpath, XPath.button(locator)).click
    end

    def drag(source_locator, target_locator)
      source = locate(:xpath, source_locator, "drag source '#{source_locator}' not found on page")
      target = locate(:xpath, target_locator, "drag target '#{target_locator}' not found on page")
      source.drag_to(target)
    end

    def fill_in(locator, options={})
      msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.fillable_field(locator), msg).set(options[:with])
    end

    def choose(locator)
      msg = "cannot choose field, no radio button with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.radio_button(locator), msg).set(true)
    end

    def check(locator)
      msg = "cannot check field, no checkbox with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.checkbox(locator), msg).set(true)
    end

    def uncheck(locator)
      msg = "cannot uncheck field, no checkbox with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.checkbox(locator), msg).set(false)
    end

    def select(value, options={})
      msg = "cannot select option, no select box with id, name, or label '#{options[:from]}' found"
      locate(:xpath, XPath.select(options[:from]), msg).select(value)
    end

    def attach_file(locator, path)
      msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.file_field(locator), msg).set(path)
    end

    def body
      driver.body
    end

    def source
      driver.source
    end

    def within(kind, scope=nil)
      kind, scope = Capybara.default_selector, kind unless scope
      scope = XPath.from_css(scope) if kind == :css
      locate(:xpath, scope, "scope '#{scope}' not found on page")
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

    def has_xpath?(path, options={})
      wait_conditionally_until do
        results = all(path, options)

        if options[:count]
          results.size == options[:count]
        else
          results.size > 0
        end
      end
    rescue Capybara::TimeoutError
      return false
    end

    def has_no_xpath?(path, options={})
      wait_conditionally_until do
        results = all(path, options)

        if options[:count]
          results.size != options[:count]
        else
          results.empty?
        end
      end
    rescue Capybara::TimeoutError
      return false
    end

    def has_css?(path, options={})
      has_xpath?(XPath.from_css(path), options)
    end

    def has_no_css?(path, options={})
      has_no_xpath?(XPath.from_css(path), options)
    end

    def has_content?(content)
      has_xpath?(XPath.content(content))
    end

    def has_no_content?(content)
      has_no_xpath?(XPath.content(content))
    end

    def save_and_open_page
      require 'capybara/save_and_open_page'
      Capybara::SaveAndOpenPage.save_and_open_page(body)
    end

    #return node identified by locator or raise ElementNotFound(using desc)
    def locate(kind_or_locator, locator=nil, fail_msg = nil)
      node = wait_conditionally_until { find(kind_or_locator, locator) }
    ensure
      raise Capybara::ElementNotFound, fail_msg || "Unable to locate '#{kind_or_locator}'" unless node
      return node
    end

    def wait_until(timeout = Capybara.default_wait_time)
      WaitUntil.timeout(timeout) { yield }
    end

    def evaluate_script(script)
      driver.evaluate_script(script)
    end

  private

    def wait_conditionally_until
      if driver.wait? then wait_until { yield } else yield end
    end

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
