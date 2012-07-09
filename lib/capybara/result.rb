module Capybara
  class Result
    include Enumerable

    def initialize(elements, query)
      @unfiltered_elements = elements
      @filtered_elements = elements.select { |node| query.matches_filters?(node) }
      @query = query
    end

    def each(&block)
      @filtered_elements.each(&block)
    end

    def first
      @filtered_elements.first
    end

    def matches_count?
      @query.matches_count?(@filtered_elements.size)
    end

    def find!
      raise find_error if @filtered_elements.count != 1
      @filtered_elements.first
    end

    def find_error
      if @filtered_elements.count == 0
        Capybara::ElementNotFound.new("Unable to find #{@query.description}")
      elsif @filtered_elements.count > 1
        Capybara::Ambiguous.new("Ambiguous match, found #{@filtered_elements.count} elements matching #{@query.description}")
      end
    end

    def failure_message
      if @query.options[:count]
        "expected #{@query.description} to be returned #{@query.options[:count]} times"
      else
        "expected #{@query.description} to return something"
      end
    end

    def negative_failure_message
      "expected #{@query.description} not to return anything"
    end

    def empty?
      @filtered_elements.empty?
    end
    def [](key); @filtered_elements[key]; end
  end
end
