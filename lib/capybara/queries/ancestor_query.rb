# frozen_string_literal: true

module Capybara
  module Queries
    class AncestorQuery < Capybara::Queries::SelectorQuery
      # @api private
      def resolve_for(node, exact = nil)
        @child_node = node
        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          node.all(:xpath, XPath.ancestor) { |el| match_results.include?(el) }
        end
      end

      def description
        child_query = @child_node && @child_node.instance_variable_get(:@query)
        desc = super
        desc += " that is an ancestor of #{child_query.description}" if child_query
        desc
      end

    private

      def valid_keys
        super - COUNT_KEYS
      end
    end
  end
end
