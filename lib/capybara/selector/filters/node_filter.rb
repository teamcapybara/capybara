# frozen_string_literal: true
require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class NodeFilter < Base
        def matches?(node, value)
          return true if skip?(value)

          if !valid_value?(value)
            msg = "Invalid value #{value.inspect} passed to filter #{@name} - "
            if default?
              warn msg + "defaulting to #{default}"
              value = default
            else
              warn msg + "skipping"
              return true
            end
          end

          @block.call(node, value)
        end
      end
    end
  end
end
