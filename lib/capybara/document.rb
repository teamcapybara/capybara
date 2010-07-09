module Capybara
  class Document < Node
    def initialize(session)
      @session = session
    end

    def all_unfiltered(locator)
      XPath.wrap(locator).paths.map do |path|
        driver.find(path)
      end.flatten
    end
  end
end
