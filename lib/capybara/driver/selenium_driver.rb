require 'selenium-webdriver'

class Capybara::Driver::Selenium < Capybara::Driver::Base
  class Node < Capybara::Driver::Node
    def text
      native.text
    end

    def [](name)
      if name == :value
        native.value
      else
        native.attribute(name.to_s)
      end
    rescue Selenium::WebDriver::Error::WebDriverError
      nil
    end

    def value
      if tag_name == "select" and self[:multiple]
        native.find_elements(:xpath, ".//option").select { |n| n.selected? }.map { |n| n.text }
      else
        self[:value]
      end
    end

    def set(value)
      if tag_name == 'input' and type == 'radio'
        native.click
      elsif tag_name == 'input' and type == 'checkbox'
        native.click if native.attribute('checked') != value
      elsif tag_name == 'textarea' or tag_name == 'input'
        native.clear
        native.send_keys(value.to_s)
      end
    end

    def select_option
      native.select
    end

    def unselect_option
      if select_node['multiple'] != 'multiple'
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

  attr_reader :app, :rack_server

  def self.driver
    unless @driver
      @driver = Selenium::WebDriver.for :firefox
      at_exit do
        @driver.quit
      end
    end
    @driver
  end

  def initialize(app)
    @app = app
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

  def browser
    self.class.driver
  end

  def cleanup!
    browser.manage.delete_all_cookies
  end

  def within_frame(frame_id)
    old_window = browser.window_handle
    browser.switch_to.frame(frame_id)
    yield
    browser.switch_to.window old_window
  end

private

  def url(path)
    rack_server.url(path)
  end

end
