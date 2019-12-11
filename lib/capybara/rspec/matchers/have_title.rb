# frozen_string_literal: true

require 'capybara/rspec/matchers/base'

module Capybara
  module RSpecMatchers
    module Matchers
      class HaveTitle < WrappedElementMatcher
        def element_matches?(el)
          el.assert_title(title, **@args[1])
        end

        def element_does_not_match?(el)
          el.assert_no_title(title, **@args[1])
        end

        def description
          "have title #{title.inspect}"
        end

      private

        def title
          @args.first
        end
      end
    end
  end
end
