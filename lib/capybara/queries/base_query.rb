# frozen_string_literal: true
module Capybara
  # @api private
  module Queries
    class BaseQuery
      COUNT_KEYS = [:count, :minimum, :maximum, :between]

      attr_reader :options
      attr_writer :session_options

      def initialize(options)
        @session_options = options.delete(:session_options)
      end

      def session_options
        @session_options || Capybara.session_options
      end

      def wait
        self.class.wait(options, session_options.default_max_wait_time)
      end

      def self.wait(options, default=Capybara.default_max_wait_time)
        options.fetch(:wait, default) || 0
      end

      ##
      #
      # Checks if a count of 0 is valid for the query
      # Returns false if query does not have any count options specified.
      #
      def expects_none?
        if COUNT_KEYS.any? { |k| options.has_key? k }
          matches_count?(0)
        else
          false
        end
      end

      ##
      #
      # Checks if the given count matches the query count options.
      # Defaults to true if no count options are specified. If multiple
      # count options exist, it tests that all conditions are met;
      # however, if :count is specified, all other options are ignored.
      #
      # @param [Integer] count     The actual number. Should be coercible via Integer()
      #
      def matches_count?(count)
        return (Integer(options[:count]) == count)     if options[:count]
        return false if options[:maximum] && (Integer(options[:maximum]) < count)
        return false if options[:minimum] && (Integer(options[:minimum]) > count)
        return false if options[:between] && !(options[:between] === count)
        return true
      end

      ##
      #
      # Generates a failure message from the query description and count options.
      #
      def failure_message
        String.new("expected to find #{description}") << count_message
      end

      def negative_failure_message
        String.new("expected not to find #{description}") << count_message
      end

      private

      def count_message
        message = String.new()
        if options[:count]
          message << " #{options[:count]} #{Capybara::Helpers.declension('time', 'times', options[:count])}"
        elsif options[:between]
          message << " between #{options[:between].first} and #{options[:between].last} times"
        elsif options[:maximum]
          message << " at most #{options[:maximum]} #{Capybara::Helpers.declension('time', 'times', options[:maximum])}"
        elsif options[:minimum]
          message << " at least #{options[:minimum]} #{Capybara::Helpers.declension('time', 'times', options[:minimum])}"
        end
        message
      end

      def assert_valid_keys
        invalid_keys = @options.keys - valid_keys
        unless invalid_keys.empty?
          invalid_names = invalid_keys.map(&:inspect).join(", ")
          valid_names = valid_keys.map(&:inspect).join(", ")
          raise ArgumentError, "invalid keys #{invalid_names}, should be one of #{valid_names}"
        end
      end
    end
  end
end
