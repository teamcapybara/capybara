# frozen_string_literal: true

module Capybara
  class Selector
    module Filters
      class Base
        def initialize(name, matcher, block, **options)
          @name = name
          @matcher = matcher
          @block = block
          @options = options
          @options[:valid_values] = [true, false] if options[:boolean]
        end

        def default?
          @options.key?(:default)
        end

        def default
          @options[:default]
        end

        def skip?(value)
          @options.key?(:skip_if) && value == @options[:skip_if]
        end

        def matcher?
          !@matcher.nil?
        end

        def handles_option?(option_name)
          if matcher?
            option_name =~ @matcher
          else
            @name == option_name
          end
        end

      private

        def apply(subject, name, value, skip_value)
          return skip_value if skip?(value)
          raise ArgumentError, "Invalid value #{value.inspect} passed to #{self.class.name.split('::').last} #{name}#{" : #{@name}" if @name.is_a?(Regexp)}" unless valid_value?(value)
          if @block.arity == 2
            @block.call(subject, value)
          else
            @block.call(subject, name, value)
          end
        end

        def valid_value?(value)
          return true unless @options.key?(:valid_values)
          Array(@options[:valid_values]).any? { |valid| valid === value } # rubocop:disable Style/CaseEquality
        end
      end
    end
  end
end
