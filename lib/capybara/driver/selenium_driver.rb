require 'selenium-webdriver'

class Capybara::Driver::Selenium < Capybara::Driver::Base
  class Node < Capybara::Node
    def text
      node.text
    end

    def [](name)
      if name == :value
        node.value
      else
        node.attribute(name)
      end
    rescue Selenium::WebDriver::Error::WebDriverError
      nil
    end

    def set(value)
      if tag_name == 'textarea' or (tag_name == 'input' and %w(text password hidden file).include?(type))
        node.clear
        node.send_keys(value.to_s)
      elsif tag_name == 'input' and type == 'radio'
        node.select
      elsif tag_name == 'input' and type == 'checkbox'
        node.toggle
      end
    end

    def select(option)
      node.find_element(:xpath, ".//option[contains(.,'#{option}')]").select
    rescue
      options = node.find_elements(:xpath, "//option").map { |o| "'#{o.text}'" }.join(', ')
      raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
    end

    def click
      node.click
    end

    def drag_to(element)
      node.drag_and_drop_on(element.node)
    end

    def tag_name
      node.tag_name
    end

    def visible?
      node.displayed? and node.displayed? != "false"
    end

  private

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

  def evaluate_script(script)
    browser.execute_script "return #{script}"
  end

  def browser
    self.class.driver
  end

  def cleanup!
    browser.manage.delete_all_cookies
  end

private

  def url(path)
    rack_server.url(path)
  end

end
