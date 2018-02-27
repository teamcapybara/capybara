# frozen_string_literal: true

module Capybara
  # @api private
  module Queries
    class TextQuery < BaseQuery
      def initialize(type = nil, expected_text, session_options:, **options) # rubocop:disable Style/OptionalArguments
        @type = if type.nil?
          Capybara.ignore_hidden_elements || Capybara.visible_text_only ? :visible : :all
        else
          type
        end
        @expected_text = if expected_text.is_a?(Regexp)
          expected_text
        else
          Capybara::Helpers.normalize_whitespace(expected_text)
        end
        @options = options
        super(@options)
        self.session_options = session_options

        @search_regexp = Capybara::Helpers.to_regexp(@expected_text, nil, exact?)

        assert_valid_keys
      end

      def resolve_for(node)
        @node = node
        @actual_text = text(node, @type)
        @count = @actual_text.scan(@search_regexp).size
      end

      def failure_message
        super << build_message(true)
      end

      def negative_failure_message
        super << build_message(false)
      end

      def description
        if @expected_text.is_a?(Regexp)
          "text matching #{@expected_text.inspect}"
        else
          "#{"exact " if exact?}text #{@expected_text.inspect}"
        end
      end

    private

      def exact?
        options.fetch(:exact, session_options.exact_text)
      end

      def build_message(report_on_invisible)
        message = +""
        unless (COUNT_KEYS & @options.keys).empty?
          message << " but found #{@count} #{Capybara::Helpers.declension('time', 'times', @count)}"
        end
        message << " in #{@actual_text.inspect}"

        details_message = []
        details_message << case_insensitive_message if @node and !@expected_text.is_a? Regexp
        details_message << invisible_message if @node and check_visible_text? and report_on_invisible
        details_message.compact!

        message << ". (However, #{details_message.join(' and ')}.)" unless details_message.empty?
        message
      end

      def case_insensitive_message
        insensitive_regexp = Capybara::Helpers.to_regexp(@expected_text, Regexp::IGNORECASE)
        insensitive_count = @actual_text.scan(insensitive_regexp).size
        if insensitive_count != @count
          "it was found #{insensitive_count} #{Capybara::Helpers.declension("time", "times", insensitive_count)} using a case insensitive search"
        end
      end

      def invisible_message
        invisible_text = text(@node, :all)
        invisible_count = invisible_text.scan(@search_regexp).size
        if invisible_count != @count
          "it was found #{invisible_count} #{Capybara::Helpers.declension("time", "times", invisible_count)} including non-visible text"
        end
      rescue # An error getting the non-visible text (if element goes out of scope) should not affect the response
      end

      def valid_keys
        COUNT_KEYS + %i[wait exact]
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
