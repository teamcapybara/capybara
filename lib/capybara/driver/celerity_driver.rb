class Capybara::Driver::Celerity < Capybara::Driver::Base
  class Node < Capybara::Driver::Node
    def text
      native.text
    end

    def [](name)
      value = if name.to_sym == :class
        native.class_name
      else
        native.send(name.to_sym)
      end
      return value if value and not value.to_s.empty?
    end

    def value
      if tag_name == "select" and native.multiple?
        native.selected_options
      else
        self[:value]
      end
    end

    def set(value)
      native.set(value)
    end

    def select_option
      native.click
    end

    def unselect_option
      unless select_node.native.multiple?
        raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
      end

      # FIXME: couldn't find a clean way to unselect, so clear and reselect
      selected_nodes = select_node.find('.//option[@selected]')
      select_node.native.clear
      selected_nodes.each { |n| n.click unless n.path == path }
    end

    def click
      native.click
    end

    def drag_to(element)
      native.fire_event('mousedown')
      element.native.fire_event('mousemove')
      element.native.fire_event('mouseup')
    end

    def tag_name
      # FIXME: this might be the dumbest way ever of getting the tag name
      # there has to be something better...
      native.to_xml[/^\s*<([a-z0-9\-\:]+)/, 1]
    end

    def visible?
      native.visible?
    end

    def path
      native.xpath
    end

    def trigger(event)
      native.fire_event(event.to_s)
    end

    def find(locator)
      noko_node = Nokogiri::HTML(driver.body).xpath(native.xpath).first
      all_nodes = noko_node.xpath(locator).map { |n| n.path }.join(' | ')
      if all_nodes.empty? then [] else driver.find(all_nodes) end
    end

  protected

    # a reference to the select node if this is an option node
    def select_node
      find('./ancestor::select').first
    end


  end

  attr_reader :app, :rack_server

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    browser.goto(url(path))
  end

  def current_url
    browser.url
  end

  def source
    browser.html
  end

  def body
    browser.document.as_xml
  end

  def response_headers
    browser.response_headers
  end

  def status_code
    browser.status_code
  end

  def find(selector)
    browser.elements_by_xpath(selector).map { |node| Node.new(self, node) }
  end

  def wait?; true; end

  def execute_script(script)
    browser.execute_script script
    nil
  end

  def evaluate_script(script)
    browser.execute_script "#{script}"
  end

  def browser
    unless @_browser
      require 'celerity'
      @_browser = ::Celerity::Browser.new(:browser => :firefox, :log_level => :off)
    end

    @_browser
  end

  def cleanup!
    browser.clear_cookies
  end

private

  def url(path)
    rack_server.url(path)
  end

end
