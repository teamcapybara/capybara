require 'culerity'

class Capybara::Driver::Culerity
  class Node < Capybara::Node
    def text
      node.text
    end

    def [](name)
      value = if name.to_sym == :class
        node.class_name
      else
        node.send(name.to_sym)
      end
      return value if value and not value.empty?
    end

    def set(value)
      node.set(value)
    end

    def select(option)
      node.select(option)
    end

    def click
      node.click
    end

    def drag_to(element)
      node.fire_event('mousedown')
      element.node.fire_event('mousemove')
      element.node.fire_event('mouseup')
    end

    def tag_name
      # FIXME: this might be the dumbest way ever of getting the tag name
      # there has to be something better...
      node.to_xml[/^\s*<([a-z0-9\-\:]+)/, 1]
    end
  end

  attr_reader :app, :rack_server

  def self.server
    unless @_server
      @_server = ::Culerity::run_server
      at_exit do
        @_server.close
      end
    end
    @_server
  end

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot
  end

  def visit(path)
    browser.goto(url(path))
  end

  def body
    browser.html
  end

  def find(selector)
    browser.elements_by_xpath(selector).map { |node| Node.new(self, node) }
  end

  def evaluate_script(script)
    browser.execute_script "#{script}"
  end

private

  def url(path)
    rack_server.url(path)
  end

  def browser
    unless @_browser
      @_browser = ::Culerity::RemoteBrowserProxy.new self.class.server, {:browser => :firefox, :log_level => :off}
      at_exit do
        @_browser.exit
      end
    end
    @_browser
  end

end
