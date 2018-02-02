# frozen_string_literal: true

module Capybara
  module Queries
    class MatchQuery < Capybara::Queries::SelectorQuery
      def visible
        options.key?(:visible) ? super : :all
      end

    private

      def valid_keys
        super - COUNT_KEYS
      end
    end
  end
end
