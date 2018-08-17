# frozen_string_literal: true

module Capybara
  class Server
    class AnimationDisabler
      def self.selector_for(css_or_bool)
        case css_or_bool
        when String
          css_or_bool
        when true
          '*'
        else
          raise CapybaraError, 'Capybara.disable_animation supports either a String (the css selector to disable) or a boolean'
        end
      end

      def initialize(app)
        @app = app
        @disable_markup = DISABLE_MARKUP_TEMPLATE % AnimationDisabler.selector_for(Capybara.disable_animation)
      end

      def call(env)
        @status, @headers, @body = @app.call(env)
        return [@status, @headers, @body] unless html_content?
        response = Rack::Response.new([], @status, @headers)

        @body.each { |html| response.write insert_disable(html) }
        @body.close if @body.respond_to?(:close)

        response.finish
      end

    private

      attr_reader :disable_markup

      def html_content?
        !!(@headers['Content-Type'] =~ /html/)
      end

      def insert_disable(html)
        html.sub(%r{(</head>)}, disable_markup + '\\1')
      end

      DISABLE_MARKUP_TEMPLATE = <<~HTML
        <script defer>(typeof jQuery !== 'undefined') && (jQuery.fx.off = true);</script>
        <style>
           %s {
             transition: none !important;
             animation-duration: 0s !important;
             animation-delay: 0s !important;
          }
        </style>
      HTML
    end
  end
end
