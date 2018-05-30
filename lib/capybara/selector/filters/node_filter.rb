# frozen_string_literal: true

require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class NodeFilter < Base
        def matches?(node, name, value)
          apply(node, name, value, true)
        rescue Capybara::ElementNotFound
          false
        end
      end
    end
  end
end
