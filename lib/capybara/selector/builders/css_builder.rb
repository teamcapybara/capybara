# frozen_string_literal: true

require 'xpath'

module Capybara
  class Selector
    # @api private
    class CSSBuilder
      class << self
        def attribute_conditions(attributes)
          attributes.map do |attribute, value|
            case value
            when XPath::Expression
              raise ArgumentError, "XPath expressions are not supported for the :#{attribute} filter with CSS based selectors"
            when Regexp
              Selector::RegexpDisassembler.new(value).substrings.map do |str|
                "[#{attribute}*='#{str}'#{' i' if value.casefold?}]"
              end.join
            when true
              "[#{attribute}]"
            when false
              ':not([attribute])'
            else
              if attribute == :id
                "##{::Capybara::Selector::CSS.escape(value)}"
              else
                "[#{attribute}='#{value}']"
              end
            end
          end.join
        end

        def class_conditions(classes)
          case classes
          when XPath::Expression
            raise ArgumentError, 'XPath expressions are not supported for the :class filter with CSS based selectors'
          when Regexp
            attribute_conditions(class: classes)
          else
            cls = Array(classes).group_by { |cl| cl.start_with?('!') && !cl.start_with?('!!!') }
            (cls[false].to_a.map { |cl| ".#{Capybara::Selector::CSS.escape(cl.sub(/^!!/, ''))}" } +
            cls[true].to_a.map { |cl| ":not(.#{Capybara::Selector::CSS.escape(cl.slice(1..-1))})" }).join
          end
        end
      end
    end
  end
end
