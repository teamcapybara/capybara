# frozen_string_literal: true

require 'regexp_parser'

module Capybara
  class Selector
    # @api private
    class RegexpDisassembler
      def initialize(regexp)
        @regexp = regexp
      end

      def alternated_substrings
        @alternated_substrings ||= begin
          or_strings = process(alternation: true)
          or_strings.each { |strs| remove_and_covered(strs) }
          remove_or_covered(or_strings)
          or_strings = [] if or_strings.any?(&:empty?)
          or_strings
        end
      end

      def substrings
        @substrings ||= begin
          strs = process(alternation: false).first
          remove_and_covered(strs)
        end
      end

    private

      def remove_and_covered(strings)
        # If we have "ab" and "abcd" required - only need to check for "abcd"
        strings.delete_if do |sub_string|
          strings.any? do |cover_string|
            next if sub_string.equal? cover_string

            cover_string.include?(sub_string)
          end
        end
      end

      def remove_or_covered(or_series)
        # If we are going to match `("a" and "b") or ("ade" and "bce")` it only makes sense to match ("a" and "b")
        # Remove any of the alternated string series that fully contain any other string series
        or_series.delete_if do |and_strs|
          or_series.any? do |and_strs2|
            next if and_strs.equal? and_strs2

            and_strs2.all? { |and_str2| and_strs.any? { |str| str.include?(and_str2) } }
          end
        end
      end

      def process(alternation:)
        strs = extract_strings(Regexp::Parser.parse(@regexp), alternation: alternation)
        strs = collapse(combine(strs).map(&:flatten))
        strs.each { |str| str.map!(&:upcase) } if @regexp.casefold?
        strs
      end

      def min_repeat(exp)
        exp.quantifier&.min || 1
      end

      def fixed_repeat?(exp)
        min_repeat(exp) == (exp.quantifier&.max || 1)
      end

      def optional?(exp)
        min_repeat(exp).zero?
      end

      def combine(strs)
        suffixes = [[]]
        strs.reverse_each do |str|
          if str.is_a? Set
            prefixes = str.each_with_object([]) { |s, memo| memo.concat combine(s) }

            result = []
            prefixes.product(suffixes) { |pair| result << pair.flatten(1) }
            suffixes = result
          else
            suffixes.each do |arr|
              arr.unshift str
            end
          end
        end
        suffixes
      end

      def collapse(strs)
        strs.map do |substrings|
          substrings.slice_before(&:nil?).map(&:join).reject(&:empty?).uniq
        end
      end

      def extract_strings(expression, strings = [], alternation: false)
        expression.each do |exp| # rubocop:disable Metrics/BlockLength
          if optional?(exp) && !(alternation && zero_or_one?(exp))
            strings.push(nil)
            next
          end

          if %i[meta].include?(exp.type) && !exp.terminal? && alternation
            strings.push(alternative_strings(exp))
            next
          end

          if %i[meta set].include?(exp.type)
            strings.push(nil)
            next
          end

          if exp.terminal?
            case exp.type
            when :literal
              if zero_or_one?(exp)
                strings.push(Set.new([[''], [exp.text]]))
                next
              else
                strings.push(exp.text * min_repeat(exp))
              end
            when :escape
              if zero_or_one?(exp)
                strings.push(Set.new([[''], [exp.text]]))
                next
              else
                strings.push(exp.char * min_repeat(exp))
              end
            else
              strings.push(nil)
            end
          elsif alternation && zero_or_one?(exp)
            strings.push(Set.new([[''], extract_strings(exp, alternation: true)]))
            next
          else
            min_repeat(exp).times { extract_strings(exp, strings, alternation: alternation) }
          end
          strings.push(nil) unless fixed_repeat?(exp)
        end
        strings
      end

      def zero_or_one?(exp)
        exp.quantity == [0, 1]
      end

      def alternative_strings(expression)
        alternatives = expression.alternatives.map { |sub_exp| extract_strings(sub_exp, alternation: true) }
        if alternatives.all?(&:any?)
          Set.new(alternatives)
        else
          nil
        end
      end
    end
  end
end
