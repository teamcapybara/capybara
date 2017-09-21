# frozen_string_literal: true
module Capybara
  module Queries
    class AncestorQuery < MatchQuery
      # @api private
      def resolve_for(node, exact = nil)
        @child_node = node
        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          node.all(:xpath, XPath.ancestor) do |el|
            match_results.include?(el)
          end
        end
      end

      def description
        desc = super
        if @child_node && (child_query = @child_node.instance_variable_get(:@query))
          desc += " that is an ancestor of #{child_query.description}"
        end
        desc
      end
    end
  end
end
