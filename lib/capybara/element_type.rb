module Capybara
  class ElementType
    class Filter
      def initialize(name, block, options = {})
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

      def matches?(node, value)
        if @options.key?(:valid_values) && !Array(@options[:valid_values]).include?(value)
          warn "Invalid value #{value.inspect} passed to filter #{@name}"
        end
        @block.call(node, value)
      end
    end

    attr_reader :name, :custom_filters

    class << self
      # @api private
      def all
        @selectors ||= {}
      end

      # @api private
      def add(name, &block)
        all[name] = self.new(name.to_sym, &block)
      end

      # @api private
      def remove(name)
        all.delete(name)
      end
    end

    # @api private
    def initialize(name, &block)
      @name = name
      @custom_filters = {}
      @label = nil
      @description = nil
      instance_eval(&block)
    end

    def label(label = nil)
      @label = label if label
      @label
    end

    def filter(name, options = {}, &block)
      @custom_filters[name] = Filter.new(name, block, options)
    end

    def describe(&block)
      @description = block
    end

    # @api private
    def set_class(cls)
      @element_class = cls
    end

    # @api private
    def element_class
      @element_class || Capybara::Node::Element
    end

    # @api private
    def description(options = {})
      (@description && @description.call(options)).to_s
    end

    %w(xpath css match).each do |method_name|
      define_method(method_name) do |*args|
        # Do nothing. Capybara.add_selector takes a block that is also instance_eval'ed in scope
        #   of this class so we should provide methods of Capybara::Selector that may be used there.
      end
    end
  end
end
