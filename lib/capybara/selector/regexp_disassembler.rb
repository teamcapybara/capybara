# frozen_string_literal: true

require 'regexp_parser'

module Capybara
  class Selector
    # @api private
    class RegexpDisassembler
      def initialize(regexp)
        @regexp = regexp
      end

      def substrings
        @substrings ||= begin
          strs = extract_strings(Regexp::Parser.parse(@regexp), [+''])
          strs.map!(&:upcase) if @regexp.casefold?
          strs.reject(&:empty?).uniq
        end
      end

    private

      def min_repeat(exp)
        exp.quantifier&.min || 1
      end

      def fixed_repeat?(exp)
        min_repeat(exp) == (exp.quantifier&.max || 1)
      end

      def optional?(exp)
        min_repeat(exp).zero?
      end

      def extract_strings(expression, strings)
        expression.each do |exp|
          if optional?(exp)
            strings.push(+'')
            next
          end

          if %i[meta set].include?(exp.type)
            strings.push(+'')
            next
          end

          if exp.terminal?
            case exp.type
            when :literal
              strings.last << (exp.text * min_repeat(exp))
            when :escape
              strings.last << (exp.char * min_repeat(exp))
            else
              strings.push(+'')
            end
          else
            min_repeat(exp).times { extract_strings(exp, strings) }
          end
          strings.push(+'') unless fixed_repeat?(exp)
        end
        strings
      end
    end
  end
end
