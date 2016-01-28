require 'addressable/uri'

module Capybara
  # @api private
  module Queries
    class CurrentPathQuery < BaseQuery
      def initialize(expected_path, options = {})
        @expected_path = expected_path
        @options = {
          url: false,
          only_path: false }.merge(options)
        assert_valid_keys
      end

      def resolves_for?(session)
        @actual_path = if options[:url]
          session.current_url
        else
          if options[:only_path]
            ::Addressable::URI.parse(session.current_url).path
          else
            ::Addressable::URI.parse(session.current_url).request_uri
          end
        end

        if @expected_path.is_a? Regexp
          @actual_path.match(@expected_path)
        else
          ::Addressable::URI.parse(@expected_path) == Addressable::URI.parse(@actual_path)
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
        verb = (@expected_path.is_a?(Regexp))? 'match' : 'equal'
        "expected #{@actual_path.inspect}#{negated} to #{verb} #{@expected_path.inspect}"
      end

      def valid_keys
        [:wait, :url, :only_path]
      end

      def assert_valid_keys
        super
        if options[:url] && options[:only_path]
          raise ArgumentError, "the :url and :only_path options cannot both be true"
        end
      end
    end
  end
end
