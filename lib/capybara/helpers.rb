# encoding: UTF-8

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
    def to_regexp(text)
      text.is_a?(Regexp) ? text : Regexp.new(Regexp.escape(normalize_whitespace(text)))
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
      if Capybara.asset_host
        if Nokogiri::HTML(html).css("base").empty? and match = html.match(/<head[^<]*?>/)
          html.clone.insert match.end(0), "<base href='#{Capybara.asset_host}' />"
        end
      else
        html
      end
    end

    ##
    #
    # Checks if the given count matches the given count options. By default,
    # when no options are given, count should be larger than zero.
    #
    # @param [Integer] count     The actual number. Should be coercible via Integer()
    # @option [Range] between    Count must be within the given range
    # @option [Integer] count    Count must be exactly this
    # @option [Integer] maximum  Count must be smaller than or equal to this value
    # @option [Integer] minimum  Count must be larger than or equal to this value
    #
    def matches_count?(count, options={})
      case
      when options[:between]
        options[:between] === count
      when options[:count]
        Integer(options[:count]) == count
      when options[:maximum]
        Integer(options[:maximum]) >= count
      when options[:minimum]
        Integer(options[:minimum]) <= count
      else
        count > 0
      end
    end

    ##
    #
    # Generates a failure message given a description of the query and count
    # options.
    #
    # @param [String] description   Description of a query
    # @option [Range] between       Count should have been within the given range
    # @option [Integer] count       Count should have been exactly this
    # @option [Integer] maximum     Count should have been smaller than or equal to this value
    # @option [Integer] minimum     Count should have been larger than or equal to this value
    #
    def failure_message(description, options={})
      message = "expected to find #{description}"
      if options[:count]
        message << " #{options[:count]} #{declension('time', 'times', options[:count])}"
      elsif options[:between]
        message << " between #{options[:between].first} and #{options[:between].last} times"
      elsif options[:maximum]
        message << " at most #{options[:maximum]} #{declension('time', 'times', options[:maximum])}"
      elsif options[:minimum]
        message << " at least #{options[:minimum]} #{declension('time', 'times', options[:minimum])}"
      end
      message
    end

    ##
    #
    # A poor man's `pluralize`. Given two declensions, one singular and one
    # plural, as well as a count, this will pick the correct declension. This
    # way we can generate gramatically correct error message.
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
  end
end
