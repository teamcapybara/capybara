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
        block.call(next_result)
      end
      self
    end

    def [](*args)
      if (args.size == 1) && ((idx = args[0]).is_a? Integer) && (idx >= 0)
        @result_cache << @results_enum.next while @result_cache.size <= idx
        @result_cache[idx]
      else
        full_results[*args]
      end
    rescue StopIteration
      return nil
    end
    alias :at :[]

    def empty?
      !any?
    end

    def matches_count? # rubocop:disable Metrics/MethodLength
      # Only check filters for as many elements as necessary to determine result
      if @query.options[:count]
        count_opt = Integer(@query.options[:count])
        loop do
          break if @result_cache.size > count_opt
          @result_cache << @results_enum.next
        end
        return @result_cache.size == count_opt
      end

      if @query.options[:minimum]
        min_opt = Integer(@query.options[:minimum])
        begin
          @result_cache << @results_enum.next while @result_cache.size < min_opt
        rescue StopIteration
          return false
        end
      end

      if @query.options[:maximum]
        max_opt = Integer(@query.options[:maximum])
        begin
          @result_cache << @results_enum.next while @result_cache.size <= max_opt
          return false
        rescue StopIteration # rubocop:disable Lint/HandleExceptions
        end
      end

      if @query.options[:between]
        max =  Integer(@query.options[:between].max)
        loop do
          break if @result_cache.size > max
          @result_cache << @results_enum.next
        end
        return false unless (@query.options[:between] === @result_cache.size)
      end

      return true
    end

    def failure_message
      message = @query.failure_message
      if count > 0
        message << ", found #{count} #{Capybara::Helpers.declension("match", "matches", count)}: " << full_results.map(&:text).map(&:inspect).join(", ")
      else
        message << " but there were no matches"
      end
      unless rest.empty?
        elements = rest.map(&:text).map(&:inspect).join(", ")
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
        @elements.select(&block).to_enum  # non-lazy evaluation
      elsif @elements.respond_to? :lazy  #Ruby 2.0+
        @elements.lazy.select(&block)
      else
        Enumerator.new do |yielder|
          @elements.each do |val|
            yielder.yield(val) if block.call(val)
          end
        end
      end
    end
  end
end
