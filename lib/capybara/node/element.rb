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

      def initialize(session, base, parent, query)
        super(session, base)
        @parent = parent
        @query = query
      end

      def allow_reload!
        @allow_reload = true
      end

      ##
      #
      # @return [Object]    The native element from the driver, this allows access to driver specific methods
      #
      def native
        synchronize { base.native }
      end

      ##
      #
      # Retrieve the text of the element. If `Capybara.ignore_hidden_elements`
      # is `true`, which it is by default, then this will return only text
      # which is visible. The exact semantics of this may differ between
      # drivers, but generally any text within elements with `display:none` is
      # ignored. This behaviour can be overridden by passing `:all` to this
      # method.
      #
      # @param [:all, :visible] type  Whether to return only visible or all text
      # @return [String]              The text of the element
      #
      def text(type=nil)
        type ||= :all unless Capybara.ignore_hidden_elements or Capybara.visible_text_only
        synchronize do
          if type == :all
            base.all_text
          else
            base.visible_text
          end
        end
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
        synchronize { base[attribute] }
      end

      ##
      #
      # @return [String]    The value of the form element
      #
      def value
        synchronize { base.value }
      end

      ##
      #
      # Set the value of the form element to the given value.
      #
      # @param [String] value    The new value
      #
      def set(value)
        synchronize { base.set(value) }
      end

      ##
      #
      # Select this node if is an option element inside a select tag
      #
      def select_option
        synchronize { base.select_option }
      end

      ##
      #
      # Unselect this node if is an option element inside a multiple select tag
      #
      def unselect_option
        synchronize { base.unselect_option }
      end

      ##
      #
      # Click the Element
      #
      def click
        synchronize { base.click }
      end

      ##
      #
      # Hover on the Element
      #
      def hover
        synchronize { base.hover }
      end

      ##
      #
      # @return [String]      The tag name of the element
      #
      def tag_name
        synchronize { base.tag_name }
      end

      ##
      #
      # Whether or not the element is visible. Not all drivers support CSS, so
      # the result may be inaccurate.
      #
      # @return [Boolean]     Whether the element is visible
      #
      def visible?
        synchronize { base.visible? }
      end

      ##
      #
      # Whether or not the element is checked.
      #
      # @return [Boolean]     Whether the element is checked
      #
      def checked?
        synchronize { base.checked? }
      end

      ##
      #
      # Whether or not the element is selected.
      #
      # @return [Boolean]     Whether the element is selected
      #
      def selected?
        synchronize { base.selected? }
      end

      ##
      #
      # Whether or not the element is disabled.
      #
      # @return [Boolean]     Whether the element is disabled
      #
      def disabled?
        synchronize { base.disabled? }
      end

      ##
      #
      # An XPath expression describing where on the page the element can be found
      #
      # @return [String]      An XPath expression
      #
      def path
        synchronize { base.path }
      end

      ##
      #
      # Trigger any event on the current element, for example mouseover or focus
      # events. Does not work in Selenium.
      #
      # @param [String] event       The name of the event to trigger
      #
      def trigger(event)
        synchronize { base.trigger(event) }
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
        synchronize { base.drag_to(node.base) }
      end

      def reload
        if @allow_reload
          begin
            reloaded = parent.reload.first(@query.name, @query.locator, @query.options)
            @base = reloaded.base if reloaded
          rescue => e
            raise e unless catch_error?(e)
          end
        end
        self
      end

      def inspect
        %(#<Capybara::Element tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError, 'Capybara::Node::Element#inspect'
        %(#<Capybara::Element tag="#{tag_name}">)
      end
    end
  end
end
