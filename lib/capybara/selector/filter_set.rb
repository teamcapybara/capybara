# frozen_string_literal: true

require 'capybara/selector/filter'

module Capybara
  class Selector
    class FilterSet
      attr_reader :node_filters, :expression_filters

      def initialize(name, &block)
        @name = name
        @node_filters = {}
        @expression_filters = {}
        @descriptions = Hash.new { |h, k| h[k] = [] }
        instance_eval(&block)
      end

      def node_filter(name, *types_and_options, &block)
        add_filter(name, Filters::NodeFilter, *types_and_options, &block)
      end
      alias_method :filter, :node_filter

      def expression_filter(name, *types_and_options, &block)
        add_filter(name, Filters::ExpressionFilter, *types_and_options, &block)
      end

      def describe(what = nil, &block)
        case what
        when nil
          undeclared_descriptions.push block
        when :node_filters
          node_filter_descriptions.push block
        when :expression_filters
          expression_filter_descriptions.push block
        else
          raise ArgumentError, 'Unknown description type'
        end
      end

      def description(node_filters: true, expression_filters: true, **options)
        opts = options_with_defaults(options)
        d = +''
        d += undeclared_descriptions.map { |desc| desc.call(opts).to_s }.join
        d += expression_filter_descriptions.map { |desc| desc.call(opts).to_s }.join if expression_filters
        d += node_filter_descriptions.map { |desc| desc.call(opts).to_s }.join if node_filters
        d
      end

      def descriptions
        warn 'DEPRECATED: FilterSet#descriptions is deprecated without replacement'
        [undeclared_descriptions, node_filter_descriptions, expression_filter_descriptions].flatten
      end

      def import(name, filters = nil)
        f_set = self.class.all[name]
        filter_selector = filters.nil? ? ->(*) { true } : ->(n, _) { filters.include? n }

        expression_filters.merge!(f_set.expression_filters.select(&filter_selector))
        node_filters.merge!(f_set.node_filters.select(&filter_selector))

        f_set.undeclared_descriptions.each { |desc| describe(&desc) }
        f_set.expression_filter_descriptions.each { |desc| describe(:expression_filters, &desc) }
        f_set.node_filter_descriptions.each { |desc| describe(:node_filters, &desc) }
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

    protected

      def undeclared_descriptions
        @descriptions[:undeclared]
      end

      def node_filter_descriptions
        @descriptions[:node_filters]
      end

      def expression_filter_descriptions
        @descriptions[:expression_filters]
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
