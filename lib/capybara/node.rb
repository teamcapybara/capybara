module Capybara
  class Node
    include Searchable

    attr_reader :driver, :node

    def initialize(driver, node)
      @driver = driver
      @node = node
    end

    def text
      raise "Not implemented"
    end

    def [](name)
      raise "Not implemented"
    end

    def value
      self[:value]
    end

    def set(value)
      raise "Not implemented"
    end

    def select(option)
      raise "Not implemented"
    end

    def click
      raise "Not implemented"
    end

    def drag_to(element)
      raise "Not implemented"
    end

    def tag_name
      raise "Not implemented"
    end

    def visible?
      raise "Not implemented"
    end

    def path
      raise NotSupportedByDriverError
    end

    private

    def all_unfiltered(locator)
      nodes = XPath.wrap(locator).scope(path).paths.map do |path|
        driver.find(path)
      end.flatten
    end

  end
end
