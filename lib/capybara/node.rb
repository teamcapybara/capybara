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
    extend Forwardable

    def_delegator :base, :text
    def_delegator :base, :[]
    def_delegator :base, :value
    def_delegator :base, :set
    def_delegator :base, :select_option
    def_delegator :base, :unselect_option
    def_delegator :base, :click
    def_delegator :base, :tag_name
    def_delegator :base, :visible?
    def_delegator :base, :path
    def_delegator :base, :trigger

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
