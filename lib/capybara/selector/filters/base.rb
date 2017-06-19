# frozen_string_literal: true
module Capybara
  class Selector
    module Filters
      class Base
        def initialize(name, block, options={})
          @name = name
          @block = block
          @options = options
          @options[:valid_values] = [true,false] if options[:boolean]
        end

        def default?
          @options.has_key?(:default)
        end

        def default
          @options[:default]
        end

        def skip?(value)
          @options.has_key?(:skip_if) && value == @options[:skip_if]
        end

        private

        def valid_value?(value)
          !@options.has_key?(:valid_values) || Array(@options[:valid_values]).include?(value)
        end
      end
    end
  end
end
