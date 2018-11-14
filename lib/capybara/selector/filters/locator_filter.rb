# frozen_string_literal: true

require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class LocatorFilter < NodeFilter
        def initialize(block, **options)
          super(nil, nil, block, options)
        end

        def matches?(node, value, context = nil)
          apply(node, nil, value, true, context)
        rescue Capybara::ElementNotFound
          false
        end
      end
    end
  end
end
