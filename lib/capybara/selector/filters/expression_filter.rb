# frozen_string_literal: true
require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class ExpressionFilter < Base
        def apply_filter(expr, value)
          return expr if skip?(value)

          if !valid_value?(value)
            msg = "Invalid value #{value.inspect} passed to expression filter #{@name} - "
            if default?
              warn msg + "defaulting to #{default}"
              value = default
            else
              warn msg + "skipping"
              return expr
            end
          end

          @block.call(expr, value)
        end
      end

      class IdentityExpressionFilter < ExpressionFilter
        def initialize
        end

        def default?
          false
        end

        def apply_filter(expr, _value)
          return expr
        end
      end
    end
  end
end