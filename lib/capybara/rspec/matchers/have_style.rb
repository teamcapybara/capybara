# frozen_string_literal: true

require 'capybara/rspec/matchers/base'

module Capybara
  module RSpecMatchers
    module Matchers
      class HaveStyle < WrappedElementMatcher
        def element_matches?(el)
          el.assert_style(*@args)
        end

        def does_not_match?(_actual)
          raise ArgumentError, 'The have_style matcher does not support use with not_to/should_not'
        end

        def description
          'have style'
        end
      end
    end
  end
end
