# frozen_string_literal: true

require 'capybara/selector/filters/base'

module Capybara
  class Selector
    module Filters
      class NodeFilter < Base
        def matches?(node, name, value, context=nil)
          apply(node, name, value, true, context)
        rescue Capybara::ElementNotFound
          false
        end
      end
    end
  end
end
