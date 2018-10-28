# frozen_string_literal: true

require 'capybara/rspec/matchers/base'

module Capybara
  module RSpecMatchers
    module Matchers
      class HaveCurrentPath < WrappedElementMatcher
        def element_matches?(el)
          el.assert_current_path(*@args)
        end

        def element_does_not_match?(el)
          el.assert_no_current_path(*@args)
        end

        def description
          "have current path #{current_path.inspect}"
        end

      private

        def current_path
          @args.first
        end
      end
    end
  end
end
