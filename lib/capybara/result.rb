require 'forwardable'

module Capybara

  ##
  # A {Capybara::Result} represents a collection of {Capybara::Element} on the page. It is possible to interact with this
  # collection similar to an Array because it implements Enumerable and offers the following Array methods through delegation:
  #
  # * []
  # * each()
  # * at()
  # * size()
  # * count()
  # * length()
  # * first()
  # * last()
  # * empty?()
  #
  # @see Capybara::Element
  #
  class Result
    include Enumerable
    extend Forwardable

    def initialize(elements, query)
      @elements = elements
      @result = elements.select { |node| query.matches_filters?(node) }
      @rest = @elements - @result
      @query = query
    end

    def_delegators :@result, :each, :[], :at, :size, :count, :length, :first, :last, :empty?

    def matches_count?
      Capybara::Helpers.matches_count?(@result.size, @query.options)
    end

    def failure_message
      message = Capybara::Helpers.failure_message(@query.description, @query.options)
      if count > 0
        message << ", found #{count} #{Capybara::Helpers.declension("match", "matches", count)}: " << @result.map(&:text).map(&:inspect).join(", ")
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
      failure_message.sub(/(to be found|to find)/, 'not \1')
    end
  end
end
