# frozen_string_literal: true
module Capybara
  # @api private
  module Queries
    class TextQuery < BaseQuery
      def initialize(*args)
        @type = (args.first.is_a?(Symbol) || args.first.nil?) ? args.shift : nil
        @expected_text, @options = args
        unless @expected_text.is_a?(Regexp)
          @expected_text = Capybara::Helpers.normalize_whitespace(@expected_text)
        end
        @search_regexp = Capybara::Helpers.to_regexp(@expected_text)
        @options ||= {}
        assert_valid_keys
      end

      def resolve_for(node)
        @actual_text = Capybara::Helpers.normalize_whitespace(node.text(@type))
        @count = @actual_text.scan(@search_regexp).size
      end

      def failure_message
        description =
          if @expected_text.is_a?(Regexp)
            "text matching #{@expected_text.inspect}"
          else
            "text #{@expected_text.inspect}"
          end

        message = Capybara::Helpers.failure_message(description, @options)
        unless (COUNT_KEYS & @options.keys).empty?
          message << " but found #{@count} #{Capybara::Helpers.declension('time', 'times', @count)}"
        end
        message << " in #{@actual_text.inspect}"
      end

      def negative_failure_message
        failure_message.sub(/(to find)/, 'not \1')
      end

      private

      def valid_keys
        COUNT_KEYS + [:wait]
      end
    end
  end
end
