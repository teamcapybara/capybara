require 'capybara/node/finders'
require 'capybara/node/actions'
require 'capybara/node/matchers'

module Capybara
  class Node
    attr_reader :session, :base

    include Capybara::Node::Finders
    include Capybara::Node::Actions
    include Capybara::Node::Matchers

    def initialize(session, base)
      @session = session
      @base = base
    end

  protected

    def driver
      session.driver
    end
  end

  class Element < Node
    def text
      base.text
    end

    def [](attribute)
      base[attribute]
    end

    def value
      base.value
    end

    def set(value)
      base.set(value)
    end

    def select_option(option)
      base.select_option(option)
    end

    def unselect_option(option)
      base.unselect_option(option)
    end

    def click
      base.click
    end

    def tag_name
      base.tag_name
    end

    def visible
      base.visible?
    end

    def path
      base.path
    end

    def trigger(event)
      base.trigger(event)
    end

    def drag_to(node)
      base.drag_to(node.base)
    end

    def inspect
      %(#<Capybara::Element tag="#{tag_name}" path="#{path}">)
    rescue NotSupportedByDriverError
      %(#<Capybara::Element tag="#{tag_name}">)
    end

  end

  class Document < Node
    def inspect
      %(#<Capybara::Document>)
    end
  end
end
