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
        text.to_s.gsub(/[[:space:]]+/, ' ').strip
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
        text.is_a?(Regexp) ? text : Regexp.new(Regexp.escape(normalize_whitespace(text)))
      end
    end
  end
end
