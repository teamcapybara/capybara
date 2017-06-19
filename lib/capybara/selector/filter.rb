# frozen_string_literal: true
require 'capybara/selector/filters/node_filter'
require 'capybara/selector/filters/expression_filter'

module Capybara
  class Selector
    def self.const_missing(const_name)
      case const_name
      when :Filter
        warn "DEPRECATED: Capybara::Selector::Filter is deprecated, please use Capybara::Selector::Filters::NodeFilter instead"
        Filters::NodeFilter
      when :ExpressionFilter
        warn "DEPRECATED: Capybara::Selector::ExpressionFilter is deprecated, please use Capybara::Selector::Filters::ExpressionFilter instead"
        Filters::ExpressionFilter
      else
        super
      end
    end
  end
end
