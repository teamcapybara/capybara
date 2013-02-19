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
        text.is_a?(Regexp) ? text : Regexp.escape(normalize_whitespace(text))
      end

      ##
      #
      # Injects a `<base>` tag into the given HTML code, pointing to
      # `Capybara.asset_host`.
      #
      # @param [String] html     HTML code to inject into
      # @param [String]          The modified HTML code
      #
      def inject_asset_host(html)
        if Capybara.asset_host
          if Nokogiri::HTML(html).css("base").empty? and match = html.match(/<head[^<]*?>/)
            html.insert match.end(0), "<base href='#{Capybara.asset_host}' />"
          end
        else
          html
        end
      end
    end
  end
end
