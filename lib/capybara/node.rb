module Capybara
  class Node
    def initialize(session, driver_node)
      @session = session
      @driver_node = driver_node
    end

    def method_missing(*args)
      @driver_node.send(*args)
    end

    def respond_to?(method)
      super || @driver_node.respond_to?(method)
    end

    def all_unfiltered(locator)
      XPath.wrap(locator).paths.map do |path|
        @driver_node.send(:all_unfiltered, path)
      end.flatten
    end

    def click_link_or_button(locator)
      msg = "no link or button '#{locator}' found"
      locate(:xpath, XPath.link(locator).button(locator), msg).click
    end

    def click_link(locator)
      msg = "no link with title, id or text '#{locator}' found"
      locate(:xpath, XPath.link(locator), msg).click
    end

    def click_button(locator)
      msg = "no button with value or id or text '#{locator}' found"
      locate(:xpath, XPath.button(locator), msg).click
    end

    def drag(source_locator, target_locator)
      source = locate(:xpath, source_locator, "drag source '#{source_locator}' not found on page")
      target = locate(:xpath, target_locator, "drag target '#{target_locator}' not found on page")
      source.drag_to(target)
    end

    def fill_in(locator, options={})
      msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
      raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
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
      locate(:xpath, XPath.select(options[:from]), msg).select_option(value)
    end

    def unselect(value, options={})
      msg = "cannot unselect option, no select box with id, name, or label '#{options[:from]}' found"
      locate(:xpath, XPath.select(options[:from]), msg).unselect_option(value)
    end

    def attach_file(locator, path)
      msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
      locate(:xpath, XPath.file_field(locator), msg).set(path)
    end

    def has_xpath?(path, options={})
      wait_conditionally_until do
        results = all(:xpath, path, options)

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
        results = all(:xpath, path, options)

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

    def has_link?(locator)
      has_xpath?(XPath.link(locator))
    end

    def has_no_link?(locator)
      has_no_xpath?(XPath.link(locator))
    end

    def has_button?(locator)
      has_xpath?(XPath.button(locator))
    end

    def has_no_button?(locator)
      has_no_xpath?(XPath.button(locator))
    end

    def has_field?(locator, options={})
      has_xpath?(XPath.field(locator, options))
    end

    def has_no_field?(locator, options={})
      has_no_xpath?(XPath.field(locator, options))
    end

    def has_checked_field?(locator)
      has_xpath?(XPath.field(locator, :checked => true))
    end

    def has_unchecked_field?(locator)
      has_xpath?(XPath.field(locator, :unchecked => true))
    end

    def has_select?(locator, options={})
      has_xpath?(XPath.select(locator, options))
    end

    def has_no_select?(locator, options={})
      has_no_xpath?(XPath.select(locator, options))
    end

    def has_table?(locator, options={})
      has_xpath?(XPath.table(locator, options))
    end

    def has_no_table?(locator, options={})
      has_no_xpath?(XPath.table(locator, options))
    end

    def save_and_open_page
      require 'capybara/save_and_open_page'
      Capybara::SaveAndOpenPage.save_and_open_page(body)
    end

    #return node identified by locator or raise ElementNotFound(using desc)
    def locate(kind_or_locator, locator=nil, fail_msg = nil)
      node = wait_conditionally_until { find(kind_or_locator, locator) }
    ensure
      raise Capybara::ElementNotFound, fail_msg || "Unable to locate '#{locator || kind_or_locator}'" unless node
      return node
    end

    def wait_until(timeout = Capybara.default_wait_time)
      Capybara.timeout(timeout,driver) { yield }
    end

    def execute_script(script)
      driver.execute_script(script)
    end

    def evaluate_script(script)
      driver.evaluate_script(script)
    end

    def find(*args)
      all(*args).first
    end

    def find_field(locator)
      find(:xpath, XPath.field(locator))
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find(:xpath, XPath.link(locator))
    end

    def find_button(locator)
      find(:xpath, XPath.button(locator))
    end

    def find_by_id(id)
      find(:css, "##{id}")
    end

    def all(*args)
      options = if args.last.is_a?(Hash) then args.pop else {} end
      if args[1].nil?
        kind, locator = Capybara.default_selector, args.first
      else
        kind, locator = args
      end
      locator = XPath.from_css(locator) if kind == :css

      results = all_unfiltered(locator)

      if options[:text]

        if options[:text].kind_of?(Regexp)
          regexp = options[:text]
        else
          regexp = Regexp.escape(options[:text]) 
        end

        results = results.select { |n| n.text.match(regexp) }
      end

      if options[:visible] or Capybara.ignore_hidden_elements
        results = results.select { |n| n.visible? }
      end

      results.map { |n| Capybara::Node.new(self, n) }
    end

  protected

    def driver
      @session.driver
    end

    def wait_conditionally_until
      if driver.wait? then wait_until { yield } else yield end
    end


  end
end
