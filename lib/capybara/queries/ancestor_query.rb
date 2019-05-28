# frozen_string_literal: true

module Capybara
  module Queries
    class AncestorQuery < Capybara::Queries::SelectorQuery
      def initialize(*args)
        super
        @count_options = {}
        COUNT_KEYS.each do |key|
          @count_options[key] = @options.delete(key) if @options.key?(key)
        end
      end

      # @api private
      def resolve_for(node, exact = nil)
        @child_node = node
        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          node.all(:xpath, XPath.ancestor, **@count_options) { |el| match_results.include?(el) }
        end
      end

      def description(applied = false)
        child_query = @child_node&.instance_variable_get(:@query)
        desc = super
        desc += " that is an ancestor of #{child_query.description}" if child_query
        desc
      end
    end
  end
end
