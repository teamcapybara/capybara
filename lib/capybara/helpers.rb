# encoding: UTF-8
# frozen_string_literal: true

module Capybara

  # @api private
  module Helpers
    extend self

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
    def to_regexp(text, regexp_options=nil, exact=false)
      if text.is_a?(Regexp)
        text
      else
        escaped = Regexp.escape(normalize_whitespace(text))
        escaped = "\\A#{escaped}\\z" if exact
        Regexp.new(escaped, regexp_options)
      end
    end

    ##
    #
    # Injects a `<base>` tag into the given HTML code, pointing to
    # `Capybara.asset_host`.
    #
    # @param [String] html     HTML code to inject into
    # @return [String]         The modified HTML code
    #
    def inject_asset_host(html)
      if Capybara.asset_host && Nokogiri::HTML(html).css("base").empty?
        match = html.match(/<head[^<]*?>/)
        if match
          return html.clone.insert match.end(0), "<base href='#{Capybara.asset_host}' />"
        end
      end

      html
    end

    ##
    #
    # A poor man's `pluralize`. Given two declensions, one singular and one
    # plural, as well as a count, this will pick the correct declension. This
    # way we can generate grammatically correct error message.
    #
    # @param [String] singular     The singular form of the word
    # @param [String] plural       The plural form of the word
    # @param [Integer] count       The number of items
    #
    def declension(singular, plural, count)
      if count == 1
        singular
      else
        plural
      end
    end

    if defined?(Process::CLOCK_MONOTONIC)
      def monotonic_time
        Process.clock_gettime Process::CLOCK_MONOTONIC
      end
    else
      def monotonic_time
        Time.now.to_f
      end
    end
  end
end
