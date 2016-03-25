module Capybara
  module Queries
    class MatchQuery < Capybara::Queries::SelectorQuery
      VALID_KEYS = [:text, :visible, :exact, :wait]

      def visible
        if options.has_key?(:visible)
          super
        else
          :all
        end
      end

      private

      def valid_keys
        VALID_KEYS + @selector.custom_filters.keys
      end
    end
  end
end