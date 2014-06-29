module Capybara
  module Driver
    class Node
      attr_reader :driver, :native

      def initialize(driver, native)
        @driver = driver
        @native = native
      end

      def all_text
        raise NotImplementedError
      end

      def visible_text
        raise NotImplementedError
      end

      def [](name)
        raise NotImplementedError
      end

      def value
        raise NotImplementedError
      end

      # @param value String or Array. Array is only allowed if node has 'multiple' attribute
      # @param options [Hash{}] Driver specific options for how to set a value on a node
      def set(value, options={})
        raise NotImplementedError
      end

      def select_option
        raise NotImplementedError
      end

      def unselect_option
        raise NotImplementedError
      end

      def click
        raise NotImplementedError
      end
      
      def right_click
        raise NotImplementedError
      end
      
      def double_click
        raise NotImplementedError
      end
      
      def hover
        raise NotImplementedError
      end
      
      def drag_to(element)
        raise NotImplementedError
      end

      def tag_name
        raise NotImplementedError
      end

      def visible?
        raise NotImplementedError
      end

      def checked?
        raise NotImplementedError
      end

      def selected?
        raise NotImplementedError
      end

      def disabled?
        raise NotImplementedError
      end

      def path
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#path'
      end

      def trigger(event)
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#trigger'
      end

      def inspect
        %(#<#{self.class} tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<#{self.class} tag="#{tag_name}">)
      end

      def ==(other)
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#=='
      end
    end
  end
end
