# frozen_string_literal: true

module Capybara
  class Selector
    # @api private
    class RegexpDisassembler
      def initialize(regexp)
        @regexp = regexp
        @regexp_source = regexp.source
      end

      def substrings
        @substrings ||= begin
          source = @regexp_source.dup
          source.gsub!(/\\[^pgk]/, '.') # replace escaped characters with wildcard
          source.gsub!(/\\[gk](?:<[^>]*>)?/, '.') # replace sub expressions and back references with wildcard
          source.gsub!(/\\p\{[[:alpha:]]+\}?/, '.') # replace character properties with wildcard
          source.gsub!(/\[\[:[a-z]+:\]\]/, '.') # replace posix classes with wildcard
          while source.gsub!(/\[(?:[^\[\]]+)\]/, '.'); end # replace character classes with wildcard
          source.gsub!(/\(\?<?[=!][^)]*\)/, '') # remove lookahead/lookbehind assertions
          source.gsub!(/\(\?(?:<[^>]+>|>|:)/, '(') # replace named, atomic, and non-matching groups with unnamed matching groups

          while source.gsub!(GROUP_REGEX) { |_m| simplify_group(Regexp.last_match) }; end
          source.gsub!(/.[*?]\??/, '.') # replace optional character with wildcard
          source.gsub!(/(.)\+\??/, '\1.') # replace one or more with character plus wildcard
          source.gsub!(/(?<char>.)#{COUNTED_REP_REGEX.source}/) do |_m| # repeat counted characters
            (Regexp.last_match[:char] * Regexp.last_match[:min_rep].to_i).tap { |str| str << '.' if Regexp.last_match[:max_rep] }
          end
          return [] if source.include?('|') # can't handle alternation here

          strs = source.match(/\A\^?(.*?)\$?\Z/).captures[0].split('.').reject(&:empty?).uniq
          strs = strs.map(&:upcase) if @regexp.casefold?
          strs
        end
      end

    private

      def simplify_group(matches)
        if matches[:group].include?('|') # no support for alternation in groups
          '.'
        elsif matches[:one_or_more] # required but may repeat becomes text + wildcard
          matches[:group][1..-2] + '.'
        elsif matches[:optional] # optional group becomes wildcard
          '.'
        elsif matches[:min_rep]
          (matches[:group] * matches[:min_rep].to_i).tap { |r| r << '.' if matches[:max_rep] }
        else
          matches[:group][1..-2]
        end
      end

      COUNTED_REP_REGEX = /\{(?<min_rep>\d*)(?:,(?<max_rep>\d*))?\}/
      GROUP_REGEX = /
        (?<group>\([^()]*\))
          (?:
            (?:
             (?<optional>[*?]) |
             (?<one_or_more>\+) |
             (?:#{COUNTED_REP_REGEX.source})
            )\??
          )?
      /x
    end
  end
end
