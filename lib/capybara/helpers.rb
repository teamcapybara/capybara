# encoding: UTF-8

module Capybara
  module Helpers
    class << self
      ##
      #
      # Normalizes whitespace space by stripping leading and trailing
      # whitespace and replacing sequences of whitespace characters
      # with a single space.
      #
      # @param [String] text     Text to normalize
      # @return [String]         Normalized text
      #
      def normalize_whitespace(text)
        # http://en.wikipedia.org/wiki/Whitespace_character#Unicode
        # We should have a better reference.
        # See also http://stackoverflow.com/a/11758133/525872
        text.to_s.gsub(/[\s\u0085\u00a0\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]+/, ' ').strip
      end

      ##
      #
      # Escapes any characters that would have special meaning in a regexp
      # if text is not a regexp
      #
      # @param [String] text Text to escape
      # @return [String]     Escaped text
      #
      def to_regexp(text)
        text.is_a?(Regexp) ? text : Regexp.escape(normalize_whitespace(text))
      end
    end
  end
end
