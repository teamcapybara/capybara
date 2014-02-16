module Capybara
  # @api private
  module Queries
    class BaseQuery
      COUNT_KEYS = [:count, :minimum, :maximum, :between]

      attr_reader :options

      def wait
        if @options.has_key?(:wait)
          @options[:wait] || 0
        else
          Capybara.default_wait_time
        end
      end

      private

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
