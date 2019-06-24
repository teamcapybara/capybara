# frozen_string_literal: true

require 'capybara/rspec/matchers/base'

module Capybara
  module RSpecMatchers
    module Matchers
      class HaveSelector < CountableWrappedElementMatcher
        def element_matches?(el)
          el.assert_selector(*@args, &@filter_block)
        end

        def element_does_not_match?(el)
          el.assert_no_selector(*@args, &@filter_block)
        end

        def description
          "have #{query.description}"
        end

        def query
          @query ||= Capybara::Queries::SelectorQuery.new(*session_query_args, &@filter_block)
        end
      end

      class HaveAllSelectors < WrappedElementMatcher
        def element_matches?(el)
          el.assert_all_of_selectors(*@args, &@filter_block)
        end

        def does_not_match?(_actual)
          raise ArgumentError, 'The have_all_selectors matcher does not support use with not_to/should_not'
        end

        def description
          'have all selectors'
        end
      end

      class HaveNoSelectors < WrappedElementMatcher
        def element_matches?(el)
          el.assert_none_of_selectors(*@args, &@filter_block)
        end

        def does_not_match?(_actual)
          raise ArgumentError, 'The have_none_of_selectors matcher does not support use with not_to/should_not'
        end

        def description
          'have no selectors'
        end
      end

      class HaveAnySelectors < WrappedElementMatcher
        def element_matches?(el)
          el.assert_any_of_selectors(*@args, &@filter_block)
        end

        def does_not_match?(_actual)
          el.assert_none_of_selectors(*@args, &@filter_block)
        end

        def description
          'have any selectors'
        end
      end
    end
  end
end
