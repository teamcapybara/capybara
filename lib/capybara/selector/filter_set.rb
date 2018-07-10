# frozen_string_literal: true

require 'capybara/selector/filter'

module Capybara
  class Selector
    class FilterSet
      attr_reader :descriptions, :node_filter_descriptions, :node_filters, :expression_filters

      def initialize(name, &block)
        @name = name
        @descriptions = []
        @node_filter_descriptions = []
        @expression_filters = {}
        @node_filters = {}
        instance_eval(&block)
      end

      def node_filter(name, *types_and_options, &block)
        add_filter(name, Filters::NodeFilter, *types_and_options, &block)
      end
      alias_method :filter, :node_filter

      def expression_filter(name, *types_and_options, &block)
        add_filter(name, Filters::ExpressionFilter, *types_and_options, &block)
      end

      def describe(node_filters: false, &block)
        if node_filters
          node_filter_descriptions.push block
        else
          descriptions.push block
        end
      end

      def description(skip_node_filters: false, **options)
        opts = options_with_defaults(options)
        d = @descriptions.map { |desc| desc.call(opts).to_s }.join
        d += @node_filter_descriptions.map { |desc| desc.call(opts).to_s }.join unless skip_node_filters
        d
      end

      class << self
        def all
          @filter_sets ||= {} # rubocop:disable Naming/MemoizedInstanceVariableName
        end

        def add(name, &block)
          all[name.to_sym] = FilterSet.new(name.to_sym, &block)
        end

        def remove(name)
          all.delete(name.to_sym)
        end
      end

    private

      def options_with_defaults(options)
        options = options.dup
        [expression_filters, node_filters].each do |filters|
          filters.select { |_n, f| f.default? }.each do |name, filter|
            options[name] = filter.default unless options.key?(name)
          end
        end
        options
      end

      def add_filter(name, filter_class, *types, matcher: nil, **options, &block)
        types.each { |k| options[k] = true }
        raise 'ArgumentError', ':default option is not supported for filters with a :matcher option' if matcher && options[:default]
        if filter_class <= Filters::ExpressionFilter
          @expression_filters[name] = filter_class.new(name, matcher, block, options)
        else
          @node_filters[name] = filter_class.new(name, matcher, block, options)
        end
      end
    end
  end
end
