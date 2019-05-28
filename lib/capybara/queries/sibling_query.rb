# frozen_string_literal: true

module Capybara
  module Queries
    class SiblingQuery < SelectorQuery
      def initialize(*args)
        super
        @count_options = {}
        COUNT_KEYS.each do |key|
          @count_options[key] = @options.delete(key) if @options.key?(key)
        end
      end

      # @api private
      def resolve_for(node, exact = nil)
        @sibling_node = node
        node.synchronize do
          match_results = super(node.session.current_scope, exact)
          xpath = XPath.preceding_sibling + XPath.following_sibling
          node.all(:xpath, xpath, **@count_options) { |el| match_results.include?(el) }
        end
      end

      def description(applied = false)
        desc = super
        sibling_query = @sibling_node&.instance_variable_get(:@query)
        desc += " that is a sibling of #{sibling_query.description}" if sibling_query
        desc
      end
    end
  end
end
