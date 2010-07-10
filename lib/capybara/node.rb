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
end
