# frozen_string_literal: true
module Capybara
  module Queries
    class SiblingQuery < MatchQuery
      # @api private
      def resolve_for(node, exact = nil)
        @sibling_node = node
        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          node.all(:xpath, XPath.preceding_sibling.union(XPath.following_sibling)) do |el|
            match_results.include?(el)
          end
        end
      end

      def description
        desc = super
        if @sibling_node && (sibling_query = @sibling_node.instance_variable_get(:@query))
          desc += " that is a sibling of #{sibling_query.description}"
        end
        desc
      end
    end
  end
end
