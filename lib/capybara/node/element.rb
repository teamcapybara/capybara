module Capybara
  module Node

    ##
    #
    # A {Capybara::Element} represents a single element on the page. It is possible
    # to interact with the contents of this element the same as with a document:
    #
    #     session = Capybara::Session.new(:rack_test, my_app)
    #
    #     bar = session.find('#bar')              # from Capybara::Node::Finders
    #     bar.select('Baz', :from => 'Quox')      # from Capybara::Node::Actions
    #
    # {Capybara::Element} also has access to HTML attributes and other properties of the
    # element:
    #
    #      bar.value
    #      bar.text
    #      bar[:title]
    #
    # @see Capybara::Node
    #
    class Element < Base

      def initialize(session, base, parent, selector)
        super(session, base)
        @parent = parent
        @selector = selector
      end

      ##
      #
      # @return [Object]    The native element from the driver, this allows access to driver specific methods
      #
      def native
        wait_until { base.native }
      end

      ##
      #
      # @return [String]    The text of the element
      #
      def text
        wait_until { base.text }
      end

      ##
      #
      # Retrieve the given attribute
      #
      #     element[:title] # => HTML title attribute
      #
      # @param  [Symbol] attribute     The attribute to retrieve
      # @return [String]               The value of the attribute
      #
      def [](attribute)
        wait_until { base[attribute] }
      end

      ##
      #
      # @return [String]    The value of the form element
      #
      def value
        wait_until { base.value }
      end

      ##
      #
      # Set the value of the form element to the given value.
      #
      # @param [String] value    The new value
      #
      def set(value)
        wait_until { base.set(value) }
      end

      ##
      #
      # Select this node if is an option element inside a select tag
      #
      def select_option
        wait_until { base.select_option }
      end

      ##
      #
      # Unselect this node if is an option element inside a multiple select tag
      #
      def unselect_option
        wait_until { base.unselect_option }
      end

      ##
      #
      # Click the Element
      #
      def click
        wait_until { base.click }
      end

      ##
      #
      # @return [String]      The tag name of the element
      #
      def tag_name
        wait_until { base.tag_name }
      end

      ##
      #
      # Whether or not the element is visible. Not all drivers support CSS, so
      # the result may be inaccurate.
      #
      # @return [Boolean]     Whether the element is visible
      #
      def visible?
        wait_until { base.visible? }
      end

      ##
      #
      # Whether or not the element is checked.
      #
      # @return [Boolean]     Whether the element is checked
      #
      def checked?
        wait_until { base.checked? }
      end

      ##
      #
      # Whether or not the element is selected.
      #
      # @return [Boolean]     Whether the element is selected
      #
      def selected?
        wait_until { base.selected? }
      end

      ##
      #
      # An XPath expression describing where on the page the element can be found
      #
      # @return [String]      An XPath expression
      #
      def path
        wait_until { base.path }
      end

      ##
      #
      # Trigger any event on the current element, for example mouseover or focus
      # events. Does not work in Selenium.
      #
      # @param [String] event       The name of the event to trigger
      #
      def trigger(event)
        wait_until { base.trigger(event) }
      end

      ##
      #
      # Drag the element to the given other element.
      #
      #     source = page.find('#foo')
      #     target = page.find('#bar')
      #     source.drag_to(target)
      #
      # @param [Capybara::Element] node     The element to drag to
      #
      def drag_to(node)
        wait_until { base.drag_to(node.base) }
      end

      def find(*args)
        wait_until { super }
      end

      def first(*args)
        wait_until { super }
      end

      def all(*args)
        wait_until { super }
      end

      def reload
        reloaded = parent.reload.first(@selector.name, @selector.locator, @selector.options)
        @base = reloaded.base if reloaded
        self
      end

      def inspect
        %(#<Capybara::Element tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<Capybara::Element tag="#{tag_name}">)
      end
    end
  end
end
