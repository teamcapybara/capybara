# frozen_string_literal: true

require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class ExpressionFilter < Base
        def apply_filter(expr, value)
          return expr if skip?(value)
          raise "ArgumentError", "Invalid value #{value.inspect} passed to expression filter #{@name}" unless valid_value?(value)
          @block.call(expr, value)
        end
      end

      class IdentityExpressionFilter < ExpressionFilter
        def initialize; end
        def default?; false; end
        def apply_filter(expr, _value); expr; end
      end
    end
  end
end
