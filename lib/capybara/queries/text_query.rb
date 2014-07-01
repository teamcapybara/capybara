module Capybara
  # @api private
  module Queries
    class TextQuery < BaseQuery
      def initialize(*args)
        @type = args.shift if args.first.is_a?(Symbol) || args.first.nil?
        @expected_text, @options = args
        unless @expected_text.is_a?(Regexp)
          @expected_text = Capybara::Helpers.normalize_whitespace(@expected_text)
        end
        @search_regexp = Capybara::Helpers.to_regexp(@expected_text)
        @options ||= {}
        assert_valid_keys

        # this is needed to not break existing tests that may use keys supported by `Query` but not supported by `TextQuery`
        # can be removed in next minor version (> 2.4)
        invalid_keys = @options.keys - (COUNT_KEYS + [:wait])
        unless invalid_keys.empty?
          invalid_names = invalid_keys.map(&:inspect).join(", ")
          valid_names = valid_keys.map(&:inspect).join(", ")
          warn "invalid keys #{invalid_names}, should be one of #{valid_names}"
        end
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
        Capybara::Query::VALID_KEYS # can be changed to COUNT_KEYS + [:wait] in next minor version (> 2.4)
      end
    end
  end
end
