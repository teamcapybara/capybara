# frozen_string_literal: true

require 'xpath'

module Capybara
  class Selector
    class RegexpDisassembler
      def initialize(regexp)
        @regexp = regexp
        @regexp_source = regexp.source
      end

      def conditions
        condition = XPath.current
        condition = condition.uppercase if @regexp.casefold?
        substrings.map do |str|
          condition.contains(@regexp.casefold? ? str.upcase : str)
        end.reduce(:&)
      end

      def substrings
        @substrings ||= begin
          source = @regexp_source.dup
          source.gsub!(/\\[^pgk]/, '.') # replace escaped characters with wildcard
          source.gsub!(/\\p\{[[:alpha:]]+\}/, '.') # replace character properties with wildcard
          source.gsub!(/\[\[:[a-z]+:\]\]/, '.') # replace posix classes with wildcard
          while source.gsub!(/\[(?:[^\[\]]+)\]/, '.'); end # replace character classes with wildcard
          source.gsub!(/\(\?<?[=!][^)]*\)/, '') # remove lookahead/lookbehind assertions
          source.gsub!(/\(\?(?:<[^>]+>|>|:)/, '(') # replace named, atomic, and non-matching groups with unnamed matching groups

          orig_source = nil
          while source != orig_source
            orig_source = source.dup
            while source.gsub!(/\([^()]*\)[*?]\??/, '.'); end # replace optional groups with wildcard
            while source.gsub!(/(\([^()]*\))\{(\d*)\}/) { |_m| (Regexp.last_match(1) * Regexp.last_match(2).to_i) }; end # replace fixed count groups with copies
            while source.gsub!(/(\([^()]*\))\{(\d*)(?:,\d*)\}\??/) { |_m| (Regexp.last_match(1) * Regexp.last_match(2).to_i) + '.' }; end # replace counted groups with minimum copies and wildcard
            while source.gsub!(/\([^()]*\|[^)]*\)/, '.'); end # replace groups containing alternation with wildcard
            while source.gsub!(/\(([^()]*)\)\+\??/, '\1.'); end # replace one or more repeating groups with text followed by wildcard
            while source.gsub!(/\(([^()]*)\)(?![+{?*])/, '\1'); end # replace non repeating groups with text
          end
          source.gsub!(/.[*?]\??/, '.') # replace optional character with wildcard
          source.gsub!(/(.)\+\??/, '\1.') # replace one or more with character plus wildcard
          source.gsub!(/(.)\{(\d*)(?:,\d*)?\}/) { |_m| (Regexp.last_match(1) * Regexp.last_match(2).to_i) + '.' } # replace counted character with with minimum copies and wildcard
          return [] if source.include?('|') # can't handle alternation here

          source.match(/\A\^?(.*?)\$?\Z/).captures[0].split('.').reject(&:empty?).uniq
        end
      end
    end
  end
end
