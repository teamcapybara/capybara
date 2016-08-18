# frozen_string_literal: true
module Capybara
  # @api private
  module Queries
    class TextQuery < BaseQuery
      def initialize(*args)
        @type = (args.first.is_a?(Symbol) || args.first.nil?) ? args.shift : nil
        @type = (Capybara.ignore_hidden_elements or Capybara.visible_text_only) ? :visible : :all if @type.nil?
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

      def build_message(report_on_invisible)
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

        details_message = []

        if @node and !@expected_text.is_a? Regexp
          insensitive_regexp = Regexp.new(Regexp.escape(@expected_text), Regexp::IGNORECASE)
          insensitive_count = @actual_text.scan(insensitive_regexp).size
          if insensitive_count != @count
            details_message << "it was found #{insensitive_count} #{Capybara::Helpers.declension("time", "times", insensitive_count)} using a case insensitive search"
          end
        end

        if @node and check_visible_text? and report_on_invisible
          invisible_text = text(@node, :all)
          invisible_count = invisible_text.scan(@search_regexp).size
          if invisible_count != @count
            details_message << ". it was found #{invisible_count} #{Capybara::Helpers.declension("time", "times", invisible_count)} including non-visible text"
          end
        end

        message << ". (However, #{details_message.join(' and ')}.)" unless details_message.empty?

        message
      end

      def valid_keys
        COUNT_KEYS + [:wait]
      end

      def check_visible_text?
        @type == :visible
      end

      def text(node, query_type)
        Capybara::Helpers.normalize_whitespace(node.text(query_type))
      end
    end
  end
end
