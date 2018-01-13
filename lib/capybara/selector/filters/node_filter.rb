# frozen_string_literal: true

require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class NodeFilter < Base
        def matches?(node, value)
          return true if skip?(value)
          raise ArgumentError, "Invalid value #{value.inspect} passed to filter #{@name}" unless valid_value?(value)
          @block.call(node, value)
        end
      end
    end
  end
end
