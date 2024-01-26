# frozen_string_literal: true

module Capybara
  class Server
    class Checker
      TRY_HTTPS_ERRORS = [EOFError, Net::ReadTimeout, Errno::ECONNRESET].freeze

      def initialize(host, port)
        @host, @port = host, port
        @ssl = false
      end

      def request(&)
        ssl? ? https_request(&) : http_request(&)
      rescue *TRY_HTTPS_ERRORS
        res = https_request(&)
        @ssl = true
        res
      end

      def ssl?
        @ssl
      end

    private

      def http_request(&)
        make_request(read_timeout: 2, &)
      end

      def https_request(&)
        make_request(**ssl_options, &)
      end

      def make_request(**options, &)
        Net::HTTP.start(@host, @port, options.merge(max_retries: 0), &)
      end

      def ssl_options
        { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE }
      end
    end
  end
end
