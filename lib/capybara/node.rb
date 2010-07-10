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
    # TODO: maybe we should explicitely delegate?
    def method_missing(*args)
      @base.send(*args)
    end

    def respond_to?(method)
      super || @base.respond_to?(method)
    end
  end

  class Document < Node
  end
end
