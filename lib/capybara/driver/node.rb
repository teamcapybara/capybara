module Capybara
  module Driver
    class Node
      attr_reader :driver, :native

      def initialize(driver, native)
        @driver = driver
        @native = native
      end

      def text
        raise NotImplementedError
      end

      def [](name)
        raise NotImplementedError
      end

      def value
        raise NotImplementedError
      end

      # @param value String or Array. Array is only allowed if node has 'multiple' attribute
      def set(value)
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

      def path
        raise NotSupportedByDriverError
      end
      
      def trigger(event)
        raise NotSupportedByDriverError
      end

      def inspect
        %(#<#{self.class} tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<#{self.class} tag="#{tag_name}">)
      end

      def ==(other)
        raise NotSupportedByDriverError
      end
    end
  end
end
