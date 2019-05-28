# frozen_string_literal: true

require 'capybara/rspec/matchers/base'
require 'capybara/rspec/matchers/count_sugar'

module Capybara
  module RSpecMatchers
    module Matchers
      class HaveSibling < WrappedElementMatcher
        include CountSugar

        def element_matches?(el)
          el.assert_sibling(*@args, &@filter_block)
        end

        def element_does_not_match?(el)
          el.assert_no_sibling(*@args, &@filter_block)
        end

        def description
          "have sibling #{query.description}"
        end

        def query
          @query ||= Capybara::Queries::SiblingQuery.new(*session_query_args, &@filter_block)
        end
      end
    end
  end
end
