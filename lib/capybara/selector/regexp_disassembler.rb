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
          if optional?(exp) && !alternation
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
            text = case exp.type
            when :literal then exp.text
            when :escape then exp.char
            else
              strings.push(nil)
              next
            end

            if optional?(exp)
              strings.push(Set.new([[''], [text]]))
              strings.push(nil) unless max_repeat(exp) == 1
              next
            else
              strings.push(text * min_repeat(exp))
            end
          elsif optional?(exp)
            strings.push(Set.new([[''], extract_strings(exp, alternation: true)]))
            strings.push(nil) unless max_repeat(exp) == 1
            next
          else
            min_repeat(exp).times { strings.concat extract_strings(exp, alternation: alternation) }
          end
          strings.push(nil) unless fixed_repeat?(exp)
        end
        strings
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
