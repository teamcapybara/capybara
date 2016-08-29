# frozen_string_literal: true
require 'capybara/selector/filter'

module Capybara
  class Selector
    class FilterSet
      attr_reader :descriptions

      def initialize(name, &block)
        @name = name
        @descriptions = []
        instance_eval(&block)
      end

      def filter(name, *types_and_options, &block)
        options = types_and_options.last.is_a?(Hash) ? types_and_options.pop.dup : {}
        types_and_options.each { |k| options[k] = true}
        filters[name] = Filter.new(name, block, options)
      end

      def describe(&block)
        descriptions.push block
      end

      def description(options={})
        @descriptions.map {|desc| desc.call(options).to_s }.join
      end

      def filters
        @filters ||= {}
      end

      class << self
        def all
          @filter_sets ||= {}
        end

        def add(name, &block)
          all[name.to_sym] = FilterSet.new(name.to_sym, &block)
        end

        def remove(name)
          all.delete(name.to_sym)
        end
      end
    end
  end
end