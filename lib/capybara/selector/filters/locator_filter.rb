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
          super(node, nil, value, context)
        end
      end
    end
  end
end
