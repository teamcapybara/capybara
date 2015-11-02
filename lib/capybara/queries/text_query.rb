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
        @node = node
        @actual_text = text(node, @type)
        @count = @actual_text.scan(@search_regexp).size
      end

      def failure_message
        build_message(true)
      end

      def negative_failure_message
        build_message(false).sub(/(to find)/, 'not \1')
      end

      private

      def build_message(check_invisible)
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

        if @node and visible? and check_invisible
          invisible_text = text(@node, :all)
          invisible_count = invisible_text.scan(@search_regexp).size
          if invisible_count != @count
            message << ". (However, it was found #{invisible_count} time#{'s' if invisible_count != 1} including invisible text.)"
          end
        end

        message
      end

      def valid_keys
        COUNT_KEYS + [:wait]
      end

      def visible?
        @type == :visible or
            (@type.nil? and (Capybara.ignore_hidden_elements or Capybara.visible_text_only))
      end

      def text(node, query_type)
        Capybara::Helpers.normalize_whitespace(node.text(query_type))
      end

    end
  end
end
