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
      @result_cache = []
      @results_enum = lazy_select_elements { |node| query.matches_filters?(node) }
      @query = query
    end

    def_delegators :full_results, :size, :length, :last, :values_at, :inspect, :sample

    alias :index :find_index

    def each(&block)
      return enum_for(:each) unless block_given?

      @result_cache.each(&block)
      loop do
        next_result = @results_enum.next
        @result_cache << next_result
        yield next_result
      end
      self
    end

    def [](*args)
      idx, length = args
      max_idx = case idx
      when Integer
        if !idx.negative?
          length.nil? ? idx : idx + length - 1
        else
          nil
        end
      when Range
        idx.max
      end

      if max_idx.nil?
        full_results[*args]
      else
        loop do
          break if @result_cache.size > max_idx
          @result_cache << @results_enum.next
        end
        @result_cache[*args]
      end
    end
    alias :at :[]

    def empty?
      !any?
    end

    def compare_count
      # Only check filters for as many elements as necessary to determine result
      if @query.options[:count]
        count_opt = Integer(@query.options[:count])
        loop do
          break if @result_cache.size > count_opt
          @result_cache << @results_enum.next
        end
        return @result_cache.size <=> count_opt
      end

      if @query.options[:minimum]
        min_opt = Integer(@query.options[:minimum])
        begin
          @result_cache << @results_enum.next while @result_cache.size < min_opt
        rescue StopIteration
          return -1
        end
      end

      if @query.options[:maximum]
        max_opt = Integer(@query.options[:maximum])
        loop do
          return 1 if @result_cache.size > max_opt
          @result_cache << @results_enum.next
        end
      end

      if @query.options[:between]
        min, max = @query.options[:between].minmax
        loop do
          break if @result_cache.size > max
          @result_cache << @results_enum.next
        end
        return 0 if @query.options[:between].include? @result_cache.size
        return @result_cache.size <=> min
      end

      0
    end

    def matches_count?
      compare_count.zero?
    end

    def failure_message
      message = @query.failure_message
      if count.zero?
        message << " but there were no matches"
      else
        message << ", found #{count} #{Capybara::Helpers.declension('match', 'matches', count)}: " << full_results.map(&:text).map(&:inspect).join(", ")
      end
      unless rest.empty?
        elements = rest.map { |el| el.text rescue "<<ERROR>>" }.map(&:inspect).join(", ") # rubocop:disable Style/RescueModifier
        message << ". Also found " << elements << ", which matched the selector but not all filters."
      end
      message
    end

    def negative_failure_message
      failure_message.sub(/(to find)/, 'not \1')
    end

  private

    def full_results
      loop { @result_cache << @results_enum.next }
      @result_cache
    end

    def rest
      @rest ||= @elements - full_results
    end

    def lazy_select_elements(&block)
      # JRuby has an issue with lazy enumerators which
      # causes a concurrency issue with network requests here
      # https://github.com/jruby/jruby/issues/4212
      if RUBY_PLATFORM == 'java'
        @elements.select(&block).to_enum # non-lazy evaluation
      else
        @elements.lazy.select(&block)
      end
    end
  end
end
