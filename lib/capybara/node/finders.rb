# frozen_string_literal: true
module Capybara
  module Node
    module Finders

      ##
      #
      # Find an {Capybara::Node::Element} based on the given arguments. +find+ will raise an error if the element
      # is not found.
      #
      # @!macro waiting_behavior
      #   If the driver is capable of executing JavaScript, +$0+ will wait for a set amount of time
      #   and continuously retry finding the element until either the element is found or the time
      #   expires. The length of time +find+ will wait is controlled through {Capybara.default_max_wait_time}
      #   and defaults to 2 seconds.
      #   @option options [false, Numeric] wait (Capybara.default_max_wait_time) Maximum time to wait for matching element to appear.
      #
      # +find+ takes the same options as +all+.
      #
      #     page.find('#foo').find('.bar')
      #     page.find(:xpath, './/div[contains(., "bar")]')
      #     page.find('li', text: 'Quox').click_link('Delete')
      #
      # @param (see Capybara::Node::Finders#all)
      #
      # @option options [Boolean] match        The matching strategy to use.
      #
      # @return [Capybara::Node::Element]      The found element
      # @raise  [Capybara::ElementNotFound]    If the element can't be found before time expires
      #
      def find(*args, &optional_filter_block)
        if args.last.is_a? Hash
          args.last[:session_options] = session_options
        else
          args.push(session_options: session_options)
        end
        synced_resolve Capybara::Queries::SelectorQuery.new(*args, &optional_filter_block)
      end

      ##
      #
      # Find an {Capybara::Node::Element} based on the given arguments that is also an ancestor of the element called on. +ancestor+ will raise an error if the element
      # is not found.
      #
      # +ancestor+ takes the same options as +find+.
      #
      #     element.ancestor('#foo').find('.bar')
      #     element.ancestor(:xpath, './/div[contains(., "bar")]')
      #     element.ancestor('ul', text: 'Quox').click_link('Delete')
      #
      # @param (see Capybara::Node::Finders#find)
      #
      # @!macro waiting_behavior
      #
      # @option options [Boolean] match        The matching strategy to use.
      #
      # @return [Capybara::Node::Element]      The found element
      # @raise  [Capybara::ElementNotFound]    If the element can't be found before time expires
      #
      def ancestor(*args, &optional_filter_block)
        if args.last.is_a? Hash
          args.last[:session_options] = session_options
        else
          args.push(session_options: session_options)
        end
        synced_resolve Capybara::Queries::AncestorQuery.new(*args, &optional_filter_block)
      end

      ##
      #
      # Find an {Capybara::Node::Element} based on the given arguments that is also a sibling of the element called on. +sibling+ will raise an error if the element
      # is not found.
      #
      #
      # +sibling+ takes the same options as +find+.
      #
      #     element.sibling('#foo').find('.bar')
      #     element.sibling(:xpath, './/div[contains(., "bar")]')
      #     element.sibling('ul', text: 'Quox').click_link('Delete')
      #
      # @param (see Capybara::Node::Finders#find)
      #
      # @macro waiting_behavior
      #
      # @option options [Boolean] match        The matching strategy to use.
      #
      # @return [Capybara::Node::Element]      The found element
      # @raise  [Capybara::ElementNotFound]    If the element can't be found before time expires
      #
      def sibling(*args, &optional_filter_block)
        if args.last.is_a? Hash
          args.last[:session_options] = session_options
        else
          args.push(session_options: session_options)
        end
        synced_resolve Capybara::Queries::SiblingQuery.new(*args, &optional_filter_block)
      end

      ##
      #
      # Find a form field on the page. The field can be found by its name, id or label text.
      #
      # @overload find_field([locator], options={})
      #   @param [String] locator             name, id, placeholder or text of associated label element
      #
      #   @macro waiting_behavior
      #
      #
      #   @option options [Boolean] checked       Match checked field?
      #   @option options [Boolean] unchecked     Match unchecked field?
      #   @option options [Boolean, Symbol] disabled (false)  Match disabled field?
      #                                                       * true - only finds a disabled field
      #                                                       * false - only finds an enabled field
      #                                                       * :all - finds either an enabled or disabled field
      #   @option options [Boolean] readonly      Match readonly field?
      #   @option options [String, Regexp] with   Value of field to match on
      #   @option options [String] type           Type of field to match on
      #   @option options [Boolean] multiple      Match fields that can have multiple values?
      #   @option options [String] id             Match fields that match the id attribute
      #   @option options [String] name           Match fields that match the name attribute
      #   @option options [String] placeholder    Match fields that match the placeholder attribute
      #   @option options [String, Array<String>] Match fields that match the class(es) passed
      # @return [Capybara::Node::Element]   The found element
      #

      def find_field(locator=nil, options={}, &optional_filter_block)
        locator, options = nil, locator if locator.is_a? Hash
        find(:field, locator, options, &optional_filter_block)
      end
      alias_method :field_labeled, :find_field

      ##
      #
      # Find a link on the page. The link can be found by its id or text.
      #
      # @overload find_link([locator], options={})
      #   @param [String] locator            id, title, text, or alt of enclosed img element
      #
      #   @macro waiting_behavior
      #
      #   @option options [String,Regexp,nil] href        Value to match against the links href, if nil finds link placeholders (<a> elements with no href attribute)
      #   @option options [String] id                 Match links with the id provided
      #   @option options [String] title              Match links with the title provided
      #   @option options [String] alt                Match links with a contained img element whose alt matches
      #   @option options [String, Array<String>] class    Match links that match the class(es) provided
      # @return [Capybara::Node::Element]   The found element
      #
      def find_link(locator=nil, options={}, &optional_filter_block)
        locator, options = nil, locator if locator.is_a? Hash
        find(:link, locator, options, &optional_filter_block)
      end

      ##
      #
      # Find a button on the page.
      # This can be any \<input> element of type submit, reset, image, button or it can be a
      # \<button> element. All buttons can be found by their id, value, or title. \<button> elements can also be found
      # by their text content, and image \<input> elements by their alt attribute
      #
      # @overload find_button([locator], options={})
      #   @param [String] locator            id, value, title, text content, alt of image
      #
      #   @overload find_button(options={})
      #
      #   @macro waiting_behavior
      #
      #   @option options [Boolean, Symbol] disabled (false)  Match disabled button?
      #                                                       * true - only finds a disabled button
      #                                                       * false - only finds an enabled button
      #                                                       * :all - finds either an enabled or disabled button
      #   @option options [String] id                 Match buttons with the id provided
      #   @option options [String] title              Match buttons with the title provided
      #   @option options [String] value              Match buttons with the value provided
      #   @option options [String, Array<String>] class    Match links that match the class(es) provided
      # @return [Capybara::Node::Element]   The found element
      #
      def find_button(locator=nil, options={}, &optional_filter_block)
        locator, options = nil, locator if locator.is_a? Hash
        find(:button, locator, options, &optional_filter_block)
      end

      ##
      #
      # Find a element on the page, given its id.
      #
      # @macro waiting_behavior
      #
      # @param [String] id                  id of element
      #
      # @return [Capybara::Node::Element]   The found element
      #
      def find_by_id(id, options={}, &optional_filter_block)
        find(:id, id, options, &optional_filter_block)
      end

      ##
      # @!method all([kind = Capybara.default_selector], locator = nil, options = {})
      #
      # Find all elements on the page matching the given selector
      # and options.
      #
      # Both XPath and CSS expressions are supported, but Capybara
      # does not try to automatically distinguish between them. The
      # following statements are equivalent:
      #
      #     page.all(:css, 'a#person_123')
      #     page.all(:xpath, './/a[@id="person_123"]')
      #
      #
      # If the type of selector is left out, Capybara uses
      # {Capybara.default_selector}. It's set to :css by default.
      #
      #     page.all("a#person_123")
      #
      #     Capybara.default_selector = :xpath
      #     page.all('.//a[@id="person_123"]')
      #
      # The set of found elements can further be restricted by specifying
      # options. It's possible to select elements by their text or visibility:
      #
      #     page.all('a', text: 'Home')
      #     page.all('#menu li', visible: true)
      #
      # By default if no elements are found, an empty array is returned;
      # however, expectations can be set on the number of elements to be found which
      # will trigger Capybara's waiting behavior for the expectations to match.The
      # expectations can be set using
      #
      #     page.assert_selector('p#foo', count: 4)
      #     page.assert_selector('p#foo', maximum: 10)
      #     page.assert_selector('p#foo', minimum: 1)
      #     page.assert_selector('p#foo', between: 1..10)
      #
      # See {Capybara::Helpers#matches_count?} for additional information about
      # count matching.
      #
      # @param [Symbol] kind                       Optional selector type (:css, :xpath, :field, etc.) - Defaults to Capybara.default_selector
      # @param [String] locator                    The selector
      # @option options [String, Regexp] text      Only find elements which contain this text or match this regexp
      # @option options [String, Boolean] exact_text (Capybara.exact_text) When String the string the elements contained text must match exactly, when Boolean controls whether the :text option must match exactly
      # @option options [Boolean, Symbol] visible  Only find elements with the specified visibility:
      #                                              * true - only finds visible elements.
      #                                              * false - finds invisible _and_ visible elements.
      #                                              * :all - same as false; finds visible and invisible elements.
      #                                              * :hidden - only finds invisible elements.
      #                                              * :visible - same as true; only finds visible elements.
      # @option options [Integer] count            Exact number of matches that are expected to be found
      # @option options [Integer] maximum          Maximum number of matches that are expected to be found
      # @option options [Integer] minimum          Minimum number of matches that are expected to be found
      # @option options [Range]   between          Number of matches found must be within the given range
      # @option options [Boolean] exact            Control whether `is` expressions in the given XPath match exactly or partially
      # @option options [Integer] wait (Capybara.default_max_wait_time)  The time to wait for element count expectations to become true
      # @overload all([kind = Capybara.default_selector], locator = nil, options = {})
      # @overload all([kind = Capybara.default_selector], locator = nil, options = {}, &filter_block)
      #   @yieldparam element [Capybara::Node::Element]  The element being considered for inclusion in the results
      #   @yieldreturn [Boolean]                     Should the element be considered in the results?
      # @return [Capybara::Result]                   A collection of found elements
      #
      def all(*args, &optional_filter_block)
        if args.last.is_a? Hash
          args.last[:session_options] = session_options
        else
          args.push(session_options: session_options)
        end
        query = Capybara::Queries::SelectorQuery.new(*args, &optional_filter_block)
        synchronize(query.wait) do
          result = query.resolve_for(self)
          raise Capybara::ExpectationNotMet, result.failure_message unless result.matches_count?
          result
        end
      end
      alias_method :find_all, :all

      ##
      #
      # Find the first element on the page matching the given selector
      # and options, or nil if no element matches.  By default no waiting
      # behavior occurs, however if {Capybara.wait_on_first_by_default} is set to true
      # it will trigger Capybara's waiting behavior for a minimum of 1 matching element to be found and
      # return the first.  Waiting behavior can also be triggered by passing in any of the count
      # expectation options.
      #
      # @overload first([kind], locator, options)
      #   @param [:css, :xpath] kind                 The type of selector
      #   @param [String] locator                    The selector
      #   @param [Hash] options                      Additional options; see {#all}
      # @return [Capybara::Node::Element]            The found element or nil
      #
      def first(*args, &optional_filter_block)
        if session_options.wait_on_first_by_default
          options = if args.last.is_a?(Hash) then args.pop.dup else {} end
          args.push({minimum: 1}.merge(options))
        end
        all(*args, &optional_filter_block).first
      rescue Capybara::ExpectationNotMet
        nil
      end

      private

      def synced_resolve(query)
        synchronize(query.wait) do
          if (query.match == :smart or query.match == :prefer_exact)
            result = query.resolve_for(self, true)
            result = query.resolve_for(self, false) if result.empty? && query.supports_exact? && !query.exact?
          else
            result = query.resolve_for(self)
          end
          if query.match == :one or query.match == :smart and result.size > 1
            raise Capybara::Ambiguous.new("Ambiguous match, found #{result.size} elements matching #{query.description}")
          end
          if result.empty?
            raise Capybara::ElementNotFound.new("Unable to find #{query.description}")
          end
          result.first
        end.tap(&:allow_reload!)
      end
    end
  end
end
