# frozen_string_literal: true

module Capybara
  class Selector
    module Filters
      class Base
        def initialize(name, block, **options)
          @name = name
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
          !@options.key?(:valid_values) || Array(@options[:valid_values]).include?(value)
        end
      end
    end
  end
end
