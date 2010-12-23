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
        %(#<Capybara::Driver::Node tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<Capybara::Driver::Node tag="#{tag_name}">)
      end
    end
  end
end
