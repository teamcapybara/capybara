require 'selenium-webdriver'

class Capybara::Driver::Selenium < Capybara::Driver::Base
  class Node < Capybara::Driver::Node
    def text
      native.text
    end

    def [](name)
      if name == :value
        value
      else
        native.attribute(name.to_s)
      end
    rescue Selenium::WebDriver::Error::WebDriverError
      nil
    end

    def value
      if tag_name == "select" and self[:multiple] and not self[:multiple] == "false"
        native.find_elements(:xpath, ".//option").select { |n| n.selected? }.map { |n| n.value || n.text }
      else
        native.value
      end
    end

    def set(value)
      if tag_name == 'input' and type == 'radio'
        native.click
      elsif tag_name == 'input' and type == 'checkbox'
        native.click if value ^ native.attribute('checked').to_s.eql?("true")
      elsif tag_name == 'textarea' or tag_name == 'input'
        native.clear
        native.send_keys(value.to_s)
      end
    end

    def select_option
      native.select
    end

    def unselect_option
      if select_node['multiple'] != 'multiple' and select_node['multiple'] != 'true'
        raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
      end
      native.clear
    end

    def click
      native.click
    end

    def drag_to(element)
      native.drag_and_drop_on(element.native)
    end

    def tag_name
      native.tag_name
    end

    def visible?
      native.displayed? and native.displayed? != "false"
    end

    def find(locator)
      native.find_elements(:xpath, locator).map { |n| self.class.new(driver, n) }
    end

  private

    # a reference to the select node if this is an option node
    def select_node
      find('./ancestor::select').first
    end

    def type
      self[:type]
    end

  end

  attr_reader :app, :rack_server, :options

  def browser
    unless @browser
      @browser = Selenium::WebDriver.for(options.delete(:browser) || :firefox, options)
      at_exit do
        @browser.quit
      end
    end
    @browser
  end

  def initialize(app, options={})
    @app = app
    @options = options
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
    browser.find_elements(:xpath, selector).map { |node| Node.new(self, node) }
  end

  def wait?; true; end

  def execute_script(script)
    browser.execute_script script
  end

  def evaluate_script(script)
    browser.execute_script "return #{script}"
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    @browser.manage.delete_all_cookies if @browser
  end

  def within_frame(frame_id)
    old_window = browser.window_handle
    browser.switch_to.frame(frame_id)
    yield
    browser.switch_to.window old_window
  end

  def within_window(handle, &blk)
    browser.switch_to.window(handle, &blk)
  end

private

  def url(path)
    rack_server.url(path)
  end

end
