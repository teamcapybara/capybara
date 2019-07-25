# frozen_string_literal: true

module Capybara
  module Queries
    class AncestorQuery < Capybara::Queries::SelectorQuery
      # @api private
      def resolve_for(node, exact = nil)
        @child_node = node

        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          ancestors = node.find_xpath(XPath.ancestor.to_s)
                          .map(&method(:to_element))
                          .select { |el| match_results.include?(el) }
          Capybara::Result.new(ancestors, self)
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
