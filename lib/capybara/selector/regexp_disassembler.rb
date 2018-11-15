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
          remove_or_covered(or_strings)
          or_strings.any?(&:empty?) ? [] : or_strings
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
        # delete_if is documented to modify the array after every block iteration - this doesn't appear to be true
        # uniq the strings to prevent identical strings from removing each other
        strings.uniq!

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

        # Ensure minimum sets of strings are being or'd
        or_series.each { |strs| remove_and_covered(strs) }

        # Remove any of the alternated string series that fully contain any other string series
        or_series.delete_if do |and_strs|
          or_series.any? do |and_strs2|
            next if and_strs.equal? and_strs2

            remove_and_covered(and_strs + and_strs2) == and_strs
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

      def max_repeat(exp)
        exp.quantifier&.max || 1
      end

      def fixed_repeat?(exp)
        min_repeat(exp) == max_repeat(exp)
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

      def extract_strings(expression, alternation: false)
        strings = []
        expression.each do |exp| # rubocop:disable Metrics/BlockLength
          next strings.push(nil) if optional?(exp) && !alternation

          next strings.push(alternative_strings(exp)) if %i[meta].include?(exp.type) && !exp.terminal? && alternation

          next strings.push(nil) if %i[meta set].include?(exp.type)

          strs = if exp.terminal?
            terminal_strings(exp)
          elsif optional?(exp)
            optional_strings(exp, extract_strings(exp, alternation: true))
          else
            repeated_strings(exp, extract_strings(exp, alternation: alternation))
          end
          strings.concat(strs)
        end
        strings
      end

      def alternative_strings(expression)
        alternatives = expression.alternatives.map { |sub_exp| extract_strings(sub_exp, alternation: true) }
        alternatives.all?(&:any?) ? Set.new(alternatives) : nil
      end

      def terminal_strings(exp)
        text = case exp.type
        when :literal then exp.text
        when :escape then exp.char
        else
          return [nil]
        end

        optional?(exp) ? optional_strings(exp, text) : repeated_strings(exp, text)
      end

      def optional_strings(exp, text)
        strs = [Set.new([[''], Array(text)])]
        strs.push(nil) unless max_repeat(exp) == 1
        strs
      end

      def repeated_strings(exp, text)
        strs = Array(text * min_repeat(exp))
        strs.push(nil) unless fixed_repeat?(exp)
        strs
      end
    end
  end
end
