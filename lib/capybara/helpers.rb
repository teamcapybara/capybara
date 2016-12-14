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
    def to_regexp(text, options=nil)
      text.is_a?(Regexp) ? text : Regexp.new(Regexp.escape(normalize_whitespace(text)), options)
    end

    ##
    #
    # Updates the HTML before writing it to the temp file.
    #
    # @param [String] html                HTML code to inject into
    # @param [Capybara::Session] session  current Capybara session
    # @return [String]                    The modified HTML code
    #
    def finalise_html(html, session)
      html = inject_asset_host(html)
      html = inject_css_as_internal(html, session)
      html = inject_html_images_as_base64(html, session)
      inject_css_images_as_base64(html, session)
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
    # Injects the CSS fetched from the <link rel="stylesheet" ... /> as internal
    # CSS in the HTML
    #
    # @param [String] html                HTML code to inject into
    # @param [Capybara::Session] session  current Capybara session
    # @return [String]                    The modified HTML code
    #
    def inject_css_as_internal(html, session)
      rel_stylesheet = Nokogiri::HTML(html).css('link[rel="stylesheet"]')
                                           .attr('href').value
      session.visit(rel_stylesheet)
      css = session.driver.html

      html.gsub(%r{</head>}, "<style>#{css}</style></style>")
    end

    ##
    #
    #
    # Injects a Base64 version of the images in the <img> src attribute in the
    # HTML.
    # @param [String] html                HTML code to inject into
    # @param [Capybara::Session] session  current Capybara session
    # @return [String]                    The modified HTML code
    #
    def inject_html_images_as_base64(html, session)
      image_sources = Nokogiri::HTML(html).css('img').map do |img|
                        img.attr('src')
                      end
      image_sources.each do |img_src|
        begin
          session.visit(img_src)
          regex = %r{#{img_src}}
          image_base64 = Base64.encode64(session.driver.html)
          image_data = "data:image/gif;base64,#{image_base64}"
          html.gsub!(regex, image_data)
        rescue ActionController::RoutingError
          # Image cannot be downloaded, just ignore it.
        end
      end

      html
    end

    ##
    #
    # Injects a Base64 version of the images in the background:url() CSS rule
    # in the internal CSS.
    # @see #inject_css_as_internal
    #
    # @param [String] html                HTML code to inject into
    # @param [Capybara::Session] session  current Capybara session
    # @return [String]                    The modified HTML code
    #
    def inject_css_images_as_base64(html, session)
      image_urls = html.scan(/background(?:-image)?:\s?url\(([\/A-z\.\-0-9]+)\)/)
      image_urls.flatten.each do |img_url|
        begin
          session.visit(img_url)
          regex = %r{#{img_url}}
          image_base64 = Base64.encode64(session.driver.html).gsub(%r{\n}, '')
          image_data = "data:image/gif;base64,#{image_base64}"
          html.gsub!(regex, image_data)
        rescue ActionController::RoutingError
          # Image cannot be downloaded, just ignore it.
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
