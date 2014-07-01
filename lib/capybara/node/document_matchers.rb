module Capybara
  module Node
    module DocumentMatchers
      ##
      # Asserts that the page has the given title.
      #
      # @!macro title_query_params
      #   @overload $0(string, options = {})
      #     @param string [String]           The string that title should include
      #   @overload $0(regexp, options = {})
      #     @param regexp [Regexp]           The regexp that title should match to
      #   @option options [Numeric] :wait (Capybara.default_wait_time) Time that Capybara will wait for title to eq/match given string/regexp argument
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_title(title, options = {})
        query = Capybara::Queries::TitleQuery.new(title, options)
        synchronize(query.wait) do
          unless query.resolves_for?(self)
            raise Capybara::ExpectationNotMet, query.failure_message
          end
        end
        return true
      end

      ##
      # Asserts that the page doesn't have the given title.
      #
      # @macro title_query_params
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_no_title(title, options = {})
        query = Capybara::Queries::TitleQuery.new(title, options)
        synchronize(query.wait) do
          if query.resolves_for?(self)
            raise Capybara::ExpectationNotMet, query.negative_failure_message
          end
        end
        return true
      end

      ##
      # Checks if the page has the given title.
      #
      # @macro title_query_params
      # @return [Boolean]
      #
      def has_title?(title, options = {})
        assert_title(title, options)
      rescue Capybara::ExpectationNotMet
        return false
      end

      ##
      # Checks if the page doesn't have the given title.
      #
      # @macro title_query_params
      # @return [Boolean]
      #
      def has_no_title?(title, options = {})
        assert_no_title(title, options)
      rescue Capybara::ExpectationNotMet
        return false
      end
    end
  end
end
