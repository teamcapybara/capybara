module Capybara
  class Node
    module Finders

      ##
      #
      # Find an Element based on the given arguments. +locate+ is a stricter version of +find+.
      # Find simply returns nil if the element is not found, in contrast +locate+ will raise an
      # error if the element is not found. The error message can be customized through the
      # +:message+ option.
      #
      # If the driver is capable of executing JavaScript, locate will wait for a set amount of time
      # and continuously retry finding the element until either the element is found or the time
      # expires. The length of time +locate+ will wait is controlled through Capybara.default_wait_time
      # and defaults to 2 seconds.
      #
      # Locate takes the same options as +find+ and +all+.
      #
      #     page.locate('#foo').locate('.bar')
      #     page.locate(:xpath, '//div[contains("bar")]')
      #     page.locate('li', :text => 'Quox').click_link('Delete')
      #
      # @param (see Capybara::Node::Finders#all)
      # @return [Capybara::Element]           The found element
      # @raise  [Capybara::ElementNotFound]   If the element can't be found before time expires
      #
      def locate(*args)
        node = wait_conditionally_until { find(*args) }
      ensure
        options = if args.last.is_a?(Hash) then args.last else {} end
        raise Capybara::ElementNotFound, options[:message] || "Unable to locate '#{args[1] || args[0]}'" unless node
        return node
      end

      ##
      #
      # Find works identically to all, except that it returns only the first element found. If the element
      # cannot be found on the page, find returns nil. See also +locate+ for a stricter variation of find.
      #
      #     page.find('#contact_form').fill_in('Name', :with => 'John')
      #
      # @param (see Capybara::Node::Finders#all)
      # @return [Capybara::Element]   The found element
      #
      def find(*args)
        all(*args).first
      end

      ##
      #
      # Find a form field on the page. The field can be found by its name, id or label text.
      #
      # @param [String] locator       Which field to find
      # @return [Capybara::Element]   The found element
      #
      def find_field(locator)
        find(:xpath, XPath.field(locator))
      end
      alias_method :field_labeled, :find_field

      ##
      #
      # Find a link on the page. The link can be found by its id or text.
      #
      # @param [String] locator       Which link to find
      # @return [Capybara::Element]   The found element
      #
      def find_link(locator)
        find(:xpath, XPath.link(locator))
      end

      ##
      #
      # Find a button on the page. The link can be found by its id, name or value.
      #
      # @param [String] locator       Which button to find
      # @return [Capybara::Element]   The found element
      #
      def find_button(locator)
        find(:xpath, XPath.button(locator))
      end

      ##
      #
      # Find a element on the page, given its id.
      #
      # @param [String] locator       Which element to find
      # @return [Capybara::Element]   The found element
      #
      def find_by_id(id)
        find(:css, "##{id}")
      end

      ##
      #
      # Find all elements on the page matching the given selector
      # and options.
      #
      # Both XPath and CSS expressions are supported, but Capybara
      # does not try to automatically distinguish between them. The
      # following statements are equivalent:
      #
      #     page.all(:css, 'a#person_123')
      #     page.all(:xpath, '//a[@id="person_123"]')
      #
      #
      # If the type of selector is left out, Capybara uses
      # Capybara.default_selector. It's set to :css by default.
      #
      #     page.all("a#person_123")
      #
      #     Capybara.default_selector = :xpath
      #     page.all('//a[@id="person_123"]')
      #
      # The set of found elements can further be restricted by specifying
      # options. It's possible to select elements by their text or visibility:
      #
      #     page.all('a', :text => 'Home')
      #     page.all('#menu li', :visible => true)
      #
      # @param [:css, :xpath, String] kind_or_locator     Either the kind of selector or the selector itself
      # @param [String] locator                           The selector
      # @param [Hash{Symbol => Object}] options           Additional options
      # @option options [String] text                     Only find elements which contain this text
      # @option options [Boolean] visible                 Only find elements that are visible on the page
      # @return [Capybara::Element]                       The found elements
      #
      def all(*args)
        options = if args.last.is_a?(Hash) then args.pop else {} end

        results = XPath.wrap(normalize_locator(*args)).paths.map do |path|
          base.find(path)
        end.flatten

        if text = options[:text]
          text = Regexp.escape(text) unless text.kind_of?(Regexp)

          results = results.select { |node| node.text.match(text) }
        end

        if options[:visible] or Capybara.ignore_hidden_elements
          results = results.select { |node| node.visible? }
        end

        results.map { |n| Capybara::Element.new(session, n) }
      end

    protected

      def normalize_locator(kind, locator=nil)
        kind, locator = Capybara.default_selector, kind if locator.nil?
        locator = XPath.from_css(locator) if kind == :css
        locator
      end

      def wait_conditionally_until
        if driver.wait? then session.wait_until { yield } else yield end
      end

    end
  end
end
