# frozen_string_literal: true

module Capybara
  class Server
    class AnimationDisabler
      def initialize(app)
        @app = app
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

      def html_content?
        !!(@headers['Content-Type'] =~ /html/)
      end

      def insert_disable(html)
        html.sub(%r{(</head>)}, DISABLE_MARKUP + '\\1')
      end

      DISABLE_MARKUP = <<~HTML
        <script defer>(typeof jQuery !== 'undefined') && (jQuery.fx.off = true);</script>
        <style>
          * {
             transition: none !important;
             animation-duration: 0s !important;
             animation-delay: 0s !important;
          }
        </style>
      HTML
    end
  end
end
