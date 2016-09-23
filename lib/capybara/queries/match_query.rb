module Capybara
  module Queries
    class MatchQuery < Capybara::Queries::SelectorQuery
      def visible
        if options.has_key?(:visible)
          super
        else
          :all
        end
      end

      private

      def valid_keys
        super - COUNT_KEYS
      end
    end
  end
end