# frozen_string_literal: true

require 'addressable/uri'

module Capybara
  # @api private
  module Queries
    class CurrentPathQuery < BaseQuery
      def initialize(expected_path, **options)
        super(options)
        @expected_path = expected_path
        @options = {
          url: !@expected_path.is_a?(Regexp) && !::Addressable::URI.parse(@expected_path || '').hostname.nil?,
          ignore_query: false
        }.merge(options)
        assert_valid_keys
      end

      def resolves_for?(session)
        uri = ::Addressable::URI.parse(session.current_url)
        uri&.query = nil if options[:ignore_query]
        @actual_path = options[:url] ? uri&.to_s : uri&.request_uri

        if @expected_path.is_a? Regexp
          @actual_path.to_s.match(@expected_path)
        else
          ::Addressable::URI.parse(@expected_path) == ::Addressable::URI.parse(@actual_path)
        end
      end

      def failure_message
        failure_message_helper
      end

      def negative_failure_message
        failure_message_helper(' not')
      end

    private

      def failure_message_helper(negated = '')
        verb = @expected_path.is_a?(Regexp) ? 'match' : 'equal'
        "expected #{@actual_path.inspect}#{negated} to #{verb} #{@expected_path.inspect}"
      end

      def valid_keys
        %i[wait url ignore_query]
      end
    end
  end
end
