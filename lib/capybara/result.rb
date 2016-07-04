# frozen_string_literal: true
require 'forwardable'

module Capybara

  ##
  # A {Capybara::Result} represents a collection of {Capybara::Node::Element} on the page. It is possible to interact with this
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
  # @see Capybara::Node::Element
  #
  class Result
    include Enumerable
    extend Forwardable

    def initialize(elements, query)
      @elements = elements
      @result = elements.select { |node| query.matches_filters?(node) }
      @result.each_with_index do |el, index|
        el.instance_variable_set(:@index, index)
      end
      @rest = @elements - @result
      @query = query
    end

    def_delegators :@result, :each, :[], :at, :size, :count, :length,
                   :first, :last, :values_at, :empty?, :inspect, :sample, :index

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
      failure_message.sub(/(to find)/, 'not \1')
    end
  end
end
