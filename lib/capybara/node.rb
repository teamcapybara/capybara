module Capybara
  class Node < Session
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

    def driver
      @session.driver
    end

    def all_unfiltered(locator)
      XPath.wrap(locator).paths.map do |path|
        @driver_node.send(:all_unfiltered, path)
      end.flatten
    end
  end
end
