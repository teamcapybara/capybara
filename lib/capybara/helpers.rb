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
            html.clone.insert match.end(0), "<base href='#{Capybara.asset_host}' />"
          end
        else
          html
        end
      end
    end
  end

  module CountHelpers
    class << self
      def matches_count?(count, options={})
        case
        when options[:between]
          options[:between] === count
        when options[:count]
          options[:count].to_i == count
        when options[:maximum]
          options[:maximum].to_i >= count
        when options[:minimum]
          options[:minimum].to_i <= count
        else
          count > 0
        end
      end

      def failure_message(description, options={})
        message_prototype = "expected to find #{description} COUNT"
        message = if options[:count]
          message_prototype.sub(/COUNT/, "#{options[:count]} #{declension('time', 'times', options[:count])}")
        elsif options[:between]
          message_prototype.sub(/COUNT/, "between #{options[:between].first} and #{options[:between].last} times")
        elsif options[:maximum]
          message_prototype.sub(/COUNT/, "at most #{options[:maximum]} #{declension('time', 'times', options[:maximum])}")
        elsif options[:minimum]
          message_prototype.sub(/COUNT/, "at least #{options[:minimum]} #{declension('time', 'times', options[:minimum])}")
        else
          "expected to find #{description}"
        end
      end

      def declension(singular, plural, count)
        if count == 1
          singular
        else
          plural
        end
      end
    end
  end
end
