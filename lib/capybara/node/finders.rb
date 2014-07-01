module Capybara
  module Node
    module Finders

      ##
      #
      # Find an {Capybara::Element} based on the given arguments. +find+ will raise an error if the element
      # is not found.
      #
      # If the driver is capable of executing JavaScript, +find+ will wait for a set amount of time
      # and continuously retry finding the element until either the element is found or the time
      # expires. The length of time +find+ will wait is controlled through {Capybara.default_wait_time}
      # and defaults to 2 seconds.
      #
      # +find+ takes the same options as +all+.
      #
      #     page.find('#foo').find('.bar')
      #     page.find(:xpath, '//div[contains(., "bar")]')
      #     page.find('li', :text => 'Quox').click_link('Delete')
      #
      # @param (see Capybara::Node::Finders#all)
      # @option options [Boolean] match        The matching strategy to use.
      # @option options [false, Numeric] wait  How long to wait for the element to appear.
      #
      # @return [Capybara::Element]            The found element
      # @raise  [Capybara::ElementNotFound]    If the element can't be found before time expires
      #
      def find(*args)
        query = Capybara::Query.new(*args)
        synchronize(query.wait) do
          if query.match == :smart or query.match == :prefer_exact
            result = query.resolve_for(self, true)
            result = query.resolve_for(self, false) if result.size == 0 && !query.exact?
          else
            result = query.resolve_for(self)
          end
          if query.match == :one or query.match == :smart and result.size > 1
            raise Capybara::Ambiguous.new("Ambiguous match, found #{result.size} elements matching #{query.description}")
          end
          if result.size == 0
            raise Capybara::ElementNotFound.new("Unable to find #{query.description}")
          end
          result.first
        end.tap(&:allow_reload!)
      end

      ##
      #
      # Find a form field on the page. The field can be found by its name, id or label text.
      #
      # @param [String] locator       Which field to find
      # @return [Capybara::Element]   The found element
      #
      def find_field(locator, options={})
        find(:field, locator, options)
      end
      alias_method :field_labeled, :find_field

      ##
      #
      # Find a link on the page. The link can be found by its id or text.
      #
      # @param [String] locator       Which link to find
      # @return [Capybara::Element]   The found element
      #
      def find_link(locator, options={})
        find(:link, locator, options)
      end

      ##
      #
      # Find a button on the page. The button can be found by its id, name or value.
      #
      # @param [String] locator       Which button to find
      # @return [Capybara::Element]   The found element
      #
      def find_button(locator, options={})
        find(:button, locator, options)
      end

      ##
      #
      # Find a element on the page, given its id.
      #
      # @param [String] id            Which element to find
      # @return [Capybara::Element]   The found element
      #
      def find_by_id(id, options={})
        find(:id, id, options)
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
      # {Capybara.default_selector}. It's set to :css by default.
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
      # By default if no elements are found, an empty array is returned;
      # however, expectations can be set on the number of elements to be
      # found using:
      #
      #     page.assert_selector('p#foo', :count => 4)
      #     page.assert_selector('p#foo', :maximum => 10)
      #     page.assert_selector('p#foo', :minimum => 1)
      #     page.assert_selector('p#foo', :between => 1..10)
      #
      # See {Capybara::Helpers#matches_count?} for additional information about
      # count matching.
      #
      # @overload all([kind], locator, options)
      #   @param [:css, :xpath] kind                 The type of selector
      #   @param [String] locator                    The selector
      #   @option options [String, Regexp] text      Only find elements which contain this text or match this regexp
      #   @option options [Boolean] visible          Only find elements that are visible on the page. Setting this to false
      #                                              finds invisible _and_ visible elements.
      #   @option options [Integer] count            Exact number of matches that are expected to be found
      #   @option options [Integer] maximum          Maximum number of matches that are expected to be found
      #   @option options [Integer] minimum          Minimum number of matches that are expected to be found
      #   @option options [Range]   between          Number of matches found must be within the given range
      #   @option options [Boolean] exact            Control whether `is` expressions in the given XPath match exactly or partially
      # @return [Capybara::Result]                   A collection of found elements
      #
      def all(*args)
        query = Capybara::Query.new(*args)
        synchronize(query.wait) do
          result = query.resolve_for(self)
          raise Capybara::ExpectationNotMet, result.failure_message unless result.matches_count?
          result
        end
      end

      ##
      #
      # Find the first element on the page matching the given selector
      # and options, or nil if no element matches.
      #
      # @overload first([kind], locator, options)
      #   @param [:css, :xpath] kind                 The type of selector
      #   @param [String] locator                    The selector
      #   @param [Hash] options                      Additional options; see {#all}
      # @return [Capybara::Element]                  The found element or nil
      #
      def first(*args)
        all(*args).first
      end
    end
  end
end
