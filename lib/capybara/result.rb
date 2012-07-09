module Capybara
  class Result
    include Enumerable

    def initialize(elements, query)
      @elements = elements
      @result = elements.select { |node| query.matches_filters?(node) }
      @rest = @elements - @result
      @query = query
    end

    def each(&block)
      @result.each(&block)
    end

    def first
      @result.first
    end

    def matches_count?
      @query.matches_count?(@result.size)
    end

    def find!
      raise find_error if @result.count != 1
      @result.first
    end

    def size; @result.size; end
    alias_method :length, :size
    alias_method :count, :size

    def find_error
      if @result.count == 0
        Capybara::ElementNotFound.new("Unable to find #{@query.description}")
      elsif @result.count > 1
        Capybara::Ambiguous.new("Ambiguous match, found #{size} elements matching #{@query.description}")
      end
    end

    def failure_message
      message = if @query.options[:count]
        "expected #{@query.description} to be found #{@query.options[:count]} #{declension("time", "times", @query.options[:count])}"
      elsif @query.options[:between]
        "expected #{@query.description} to be found between #{@query.options[:between].first} and #{@query.options[:between].last} times"
      elsif @query.options[:maximum]
        "expected #{@query.description} to be found at most #{@query.options[:maximum]} #{declension("time", "times", @query.options[:maximum])}"
      elsif @query.options[:minimum]
        "expected #{@query.description} to be found at least #{@query.options[:minimum]} #{declension("time", "times", @query.options[:minimum])}"
      else
        "expected to find #{@query.description}"
      end
      if count > 0
        message << ", found #{count} #{declension("match", "matches")}: " << @result.map(&:text).map(&:inspect).join(", ")
      else
        message << " but there were no matches"
      end
      unless @rest.empty?
        elements = @rest.map(&:text).map(&:inspect).join(", ")
        message << ". Also found " << elements << ", which matched the selector but not all filters."
      end
      message
    end

    def negative_failure_message
      "expected not to find #{@query.description}, but there #{declension("was", "were")} #{count} #{declension("match", "matches")}"
    end

    def empty?
      @result.empty?
    end
    def [](key); @result[key]; end

  private

    def declension(singular, plural, count=count)
      if count == 1
        singular
      else
        plural
      end
    end
  end
end
