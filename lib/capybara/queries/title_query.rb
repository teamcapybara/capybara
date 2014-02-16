module Capybara
  # @api private
  module Queries
    class TitleQuery < BaseQuery
      def initialize(expected_title, options = {})
        @expected_title = expected_title
        @options = options
        unless @expected_title.is_a?(Regexp)
          @expected_title = Capybara::Helpers.normalize_whitespace(@expected_title)
        end
        @search_regexp = Capybara::Helpers.to_regexp(@expected_title)
        assert_valid_keys
      end

      def resolves_for?(node)
        @actual_title = node.title
        @actual_title.match(@search_regexp)
      end

      def failure_message
        failure_message_helper
      end

      def negative_failure_message
        failure_message_helper(' not')
      end

      private

      def failure_message_helper(negated = '')
        verb = (@expected_title.is_a?(Regexp))? 'match' : 'include'
        "expected #{@actual_title.inspect}#{negated} to #{verb} #{@expected_title.inspect}"
      end

      def valid_keys
        [:wait]
      end
    end
  end
end
