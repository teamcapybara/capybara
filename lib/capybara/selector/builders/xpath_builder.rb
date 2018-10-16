# frozen_string_literal: true

require 'xpath'

module Capybara
  class Selector
    # @api private
    class XPathBuilder
      class << self
        def attribute_conditions(attributes)
          attributes.map do |attribute, value|
            case value
            when XPath::Expression
              XPath.attr(attribute)[value]
            when Regexp
              XPath.attr(attribute)[regexp_to_xpath_conditions(value)]
            when true
              XPath.attr(attribute)
            when false, nil
              !XPath.attr(attribute)
            else
              XPath.attr(attribute) == value.to_s
            end
          end.reduce(:&)
        end

        def class_conditions(classes)
          case classes
          when XPath::Expression, Regexp
            attribute_conditions(class: classes)
          else
            Array(classes).map do |klass|
              if klass.start_with?('!') && !klass.start_with?('!!!')
                !XPath.attr(:class).contains_word(klass.slice(1..-1))
              else
                XPath.attr(:class).contains_word(klass.sub(/^!!/, ''))
              end
            end.reduce(:&)
          end
        end

      private

        def regexp_to_xpath_conditions(regexp)
          condition = XPath.current
          condition = condition.uppercase if regexp.casefold?
          Selector::RegexpDisassembler.new(regexp).substrings.map do |str|
            condition.contains(str)
          end.reduce(:&)
        end
      end
    end
  end
end
