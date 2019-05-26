# frozen_string_literal: true

module Capybara
  module Node
    module Matchers
      ##
      #
      # Checks if a given selector is on the page or a descendant of the current node.
      #
      #     page.has_selector?('p#foo')
      #     page.has_selector?(:xpath, './/p[@id="foo"]')
      #     page.has_selector?(:foo)
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_selector?('p.foo', count: 4)
      #
      # This will check if the expression occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      #     page.has_selector?('li', text: 'Horse', visible: true)
      #
      # {#has_selector?} can also accept XPath expressions generated by the
      # XPath gem:
      #
      #     page.has_selector?(:xpath, XPath.descendant(:p))
      #
      # @param (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)     Number of matching elements that should exist
      # @option options [Integer] :minimum (nil)   Minimum number of matching elements that should exist
      # @option options [Integer] :maximum (nil)   Maximum number of matching elements that should exist
      # @option options [Range]   :between (nil)   Range of number of matching elements that should exist
      # @return [Boolean]                       If the expression exists
      #
      def has_selector?(*args, **options, &optional_filter_block)
        make_predicate(options) { assert_selector(*args, options, &optional_filter_block) }
      end

      ##
      #
      # Checks if a given selector is not on the page or a descendant of the current node.
      # Usage is identical to {#has_selector?}.
      #
      # @param (see #has_selector?)
      # @return [Boolean]
      #
      def has_no_selector?(*args, **options, &optional_filter_block)
        make_predicate(options) { assert_no_selector(*args, options, &optional_filter_block) }
      end

      ##
      #
      # Checks if a an element has the specified CSS styles.
      #
      #     element.matches_style?( 'color' => 'rgb(0,0,255)', 'font-size' => /px/ )
      #
      # @param styles [Hash]
      # @return [Boolean]                       If the styles match
      #
      def matches_style?(styles, **options)
        make_predicate(options) { assert_matches_style(styles, options) }
      end

      ##
      # @deprecated Use {#matches_style?} instead.
      #
      def has_style?(styles, **options)
        warn 'DEPRECATED: has_style? is deprecated, please use matches_style?'
        matches_style?(styles, **options)
      end

      ##
      #
      # Asserts that a given selector is on the page or a descendant of the current node.
      #
      #     page.assert_selector('p#foo')
      #     page.assert_selector(:xpath, './/p[@id="foo"]')
      #     page.assert_selector(:foo)
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.assert_selector('p#foo', count: 4)
      #
      # This will check if the expression occurs exactly 4 times. See
      # {Capybara::Node::Finders#all} for other available result size options.
      #
      # If a `:count` of 0 is specified, it will behave like {#assert_no_selector};
      # however, use of that method is preferred over this one.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      #     page.assert_selector('li', text: 'Horse', visible: true)
      #
      # {#assert_selector} can also accept XPath expressions generated by the
      # XPath gem:
      #
      #     page.assert_selector(:xpath, XPath.descendant(:p))
      #
      # @param (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the expression should occur
      # @raise [Capybara::ExpectationNotMet]      If the selector does not exist
      #
      def assert_selector(*args, &optional_filter_block)
        _verify_selector_result(args, optional_filter_block) do |result, query|
          raise Capybara::ExpectationNotMet, result.failure_message unless result.matches_count? && (result.any? || query.expects_none?)
        end
      end

      ##
      #
      # Asserts that an element has the specified CSS styles.
      #
      #     element.assert_matches_style( 'color' => 'rgb(0,0,255)', 'font-size' => /px/ )
      #
      # @param styles [Hash]
      # @raise [Capybara::ExpectationNotMet]    If the element doesn't have the specified styles
      #
      def assert_matches_style(styles, **options)
        query_args = _set_query_session_options(styles, options)
        query = Capybara::Queries::StyleQuery.new(*query_args)
        synchronize(query.wait) do
          raise Capybara::ExpectationNotMet, query.failure_message unless query.resolves_for?(self)
        end
        true
      end

      ##
      # @deprecated Use {#assert_matches_style} instead.
      #
      def assert_style(styles, **options)
        warn 'assert_style is deprecated, please use assert_matches_style instead'
        assert_matches_style(styles, **options)
      end

      # Asserts that all of the provided selectors are present on the given page
      # or descendants of the current node.  If options are provided, the assertion
      # will check that each locator is present with those options as well (other than `:wait`).
      #
      #   page.assert_all_of_selectors(:custom, 'Tom', 'Joe', visible: all)
      #   page.assert_all_of_selectors(:css, '#my_div', 'a.not_clicked')
      #
      # It accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      # The `:wait` option applies to all of the selectors as a group, so all of the locators must be present
      # within `:wait` (defaults to {Capybara.configure default_max_wait_time}) seconds.
      #
      # @overload assert_all_of_selectors([kind = Capybara.default_selector], *locators, **options)
      #
      def assert_all_of_selectors(*args, **options, &optional_filter_block)
        _verify_multiple(*args, options) do |selector, locator, opts|
          assert_selector(selector, locator, opts, &optional_filter_block)
        end
      end

      # Asserts that none of the provided selectors are present on the given page
      # or descendants of the current node. If options are provided, the assertion
      # will check that each locator is not present with those options as well (other than `:wait`).
      #
      #   page.assert_none_of_selectors(:custom, 'Tom', 'Joe', visible: all)
      #   page.assert_none_of_selectors(:css, '#my_div', 'a.not_clicked')
      #
      # It accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      # The `:wait` option applies to all of the selectors as a group, so none of the locators must be present
      # within `:wait` (defaults to {Capybara.configure default_max_wait_time}) seconds.
      #
      # @overload assert_none_of_selectors([kind = Capybara.default_selector], *locators, **options)
      #
      def assert_none_of_selectors(*args, **options, &optional_filter_block)
        _verify_multiple(*args, options) do |selector, locator, opts|
          assert_no_selector(selector, locator, opts, &optional_filter_block)
        end
      end

      # Asserts that any of the provided selectors are present on the given page
      # or descendants of the current node. If options are provided, the assertion
      # will check that each locator is present with those options as well (other than `:wait`).
      #
      #   page.assert_any_of_selectors(:custom, 'Tom', 'Joe', visible: all)
      #   page.assert_any_of_selectors(:css, '#my_div', 'a.not_clicked')
      #
      # It accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      # The `:wait` option applies to all of the selectors as a group, so any of the locators must be present
      # within `:wait` (defaults to {Capybara.configure default_max_wait_time}) seconds.
      #
      # @overload assert_any_of_selectors([kind = Capybara.default_selector], *locators, **options)
      #
      def assert_any_of_selectors(*args, wait: nil, **options, &optional_filter_block)
        wait = session_options.default_max_wait_time if wait.nil?
        selector = extract_selector(args)
        synchronize(wait) do
          res = args.map do |locator|
            begin
              assert_selector(selector, locator, options, &optional_filter_block)
              break nil
            rescue Capybara::ExpectationNotMet => e
              e.message
            end
          end
          raise Capybara::ExpectationNotMet, res.join(' or ') if res

          true
        end
      end

      ##
      #
      # Asserts that a given selector is not on the page or a descendant of the current node.
      # Usage is identical to {#assert_selector}.
      #
      # Query options such as `:count`, `:minimum`, `:maximum`, and `:between` are
      # considered to be an integral part of the selector. This will return
      # `true`, for example, if a page contains 4 anchors but the query expects 5:
      #
      #     page.assert_no_selector('a', minimum: 1) # Found, raises Capybara::ExpectationNotMet
      #     page.assert_no_selector('a', count: 4)   # Found, raises Capybara::ExpectationNotMet
      #     page.assert_no_selector('a', count: 5)   # Not Found, returns true
      #
      # @param (see #assert_selector)
      # @raise [Capybara::ExpectationNotMet]      If the selector exists
      #
      def assert_no_selector(*args, &optional_filter_block)
        _verify_selector_result(args, optional_filter_block) do |result, query|
          if result.matches_count? && (!result.empty? || query.expects_none?)
            raise Capybara::ExpectationNotMet, result.negative_failure_message
          end
        end
      end

      ##
      #
      # Checks if a given XPath expression is on the page or a descendant of the current node.
      #
      #     page.has_xpath?('.//p[@id="foo"]')
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_xpath?('.//p[@id="foo"]', count: 4)
      #
      # This will check if the expression occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      #     page.has_xpath?('.//li', text: 'Horse', visible: true)
      #
      # {#has_xpath?} can also accept XPath expressions generated by the
      # XPath gem:
      #
      #     xpath = XPath.generate { |x| x.descendant(:p) }
      #     page.has_xpath?(xpath)
      #
      # @param [String] path                      An XPath expression
      # @param options                            (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the expression should occur
      # @return [Boolean]                         If the expression exists
      #
      def has_xpath?(path, **options, &optional_filter_block)
        has_selector?(:xpath, path, options, &optional_filter_block)
      end

      ##
      #
      # Checks if a given XPath expression is not on the page or a descendant of the current node.
      # Usage is identical to {#has_xpath?}.
      #
      # @param (see #has_xpath?)
      # @return [Boolean]
      #
      def has_no_xpath?(path, **options, &optional_filter_block)
        has_no_selector?(:xpath, path, options, &optional_filter_block)
      end

      ##
      #
      # Checks if a given CSS selector is on the page or a descendant of the current node.
      #
      #     page.has_css?('p#foo')
      #
      # By default it will check if the selector occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_css?('p#foo', count: 4)
      #
      # This will check if the selector occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      #     page.has_css?('li', text: 'Horse', visible: true)
      #
      # @param [String] path                      A CSS selector
      # @param options                            (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the selector should occur
      # @return [Boolean]                         If the selector exists
      #
      def has_css?(path, **options, &optional_filter_block)
        has_selector?(:css, path, options, &optional_filter_block)
      end

      ##
      #
      # Checks if a given CSS selector is not on the page or a descendant of the current node.
      # Usage is identical to {#has_css?}.
      #
      # @param (see #has_css?)
      # @return [Boolean]
      #
      def has_no_css?(path, **options, &optional_filter_block)
        has_no_selector?(:css, path, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a link with the given
      # text or id.
      #
      # @param [String] locator           The text or id of a link to check for
      # @option options [String, Regexp] :href    The value the href attribute must be
      # @return [Boolean]                 Whether it exists
      #
      def has_link?(locator = nil, **options, &optional_filter_block)
        has_selector?(:link, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no link with the given
      # text or id.
      #
      # @param (see #has_link?)
      # @return [Boolean]            Whether it doesn't exist
      #
      def has_no_link?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:link, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a button with the given
      # text, value or id.
      #
      # @param [String] locator      The text, value or id of a button to check for
      # @return [Boolean]            Whether it exists
      #
      def has_button?(locator = nil, **options, &optional_filter_block)
        has_selector?(:button, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no button with the given
      # text, value or id.
      #
      # @param [String] locator      The text, value or id of a button to check for
      # @return [Boolean]            Whether it doesn't exist
      #
      def has_no_button?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:button, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a form field with the given
      # label, name or id.
      #
      # For text fields and other textual fields, such as textareas and
      # HTML5 email/url/etc. fields, it's possible to specify a `:with`
      # option to specify the text the field should contain:
      #
      #     page.has_field?('Name', with: 'Jonas')
      #
      # It is also possible to filter by the field type attribute:
      #
      #     page.has_field?('Email', type: 'email')
      #
      # Note: 'textarea' and 'select' are valid type values, matching the associated tag names.
      #
      # @param [String] locator                  The label, name or id of a field to check for
      # @option options [String, Regexp] :with   The text content of the field or a Regexp to match
      # @option options [String] :type           The type attribute of the field
      # @return [Boolean]                        Whether it exists
      #
      def has_field?(locator = nil, **options, &optional_filter_block)
        has_selector?(:field, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no form field with the given
      # label, name or id. See {#has_field?}.
      #
      # @param [String] locator                  The label, name or id of a field to check for
      # @option options [String, Regexp] :with   The text content of the field or a Regexp to match
      # @option options [String] :type           The type attribute of the field
      # @return [Boolean]                        Whether it doesn't exist
      #
      def has_no_field?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:field, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a radio button or
      # checkbox with the given label, value, id, or {Capybara.configure test_id} attribute that is currently
      # checked.
      #
      # @param [String] locator           The label, name or id of a checked field
      # @return [Boolean]                 Whether it exists
      #
      def has_checked_field?(locator = nil, **options, &optional_filter_block)
        has_selector?(:field, locator, options.merge(checked: true), &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no radio button or
      # checkbox with the given label, value or id, or {Capybara.configure test_id} attribute that is currently
      # checked.
      #
      # @param [String] locator           The label, name or id of a checked field
      # @return [Boolean]                 Whether it doesn't exist
      #
      def has_no_checked_field?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:field, locator, options.merge(checked: true), &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a radio button or
      # checkbox with the given label, value or id, or {Capybara.configure test_id} attribute that is currently
      # unchecked.
      #
      # @param [String] locator           The label, name or id of an unchecked field
      # @return [Boolean]                 Whether it exists
      #
      def has_unchecked_field?(locator = nil, **options, &optional_filter_block)
        has_selector?(:field, locator, options.merge(unchecked: true), &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no radio button or
      # checkbox with the given label, value or id, or {Capybara.configure test_id} attribute that is currently
      # unchecked.
      #
      # @param [String] locator           The label, name or id of an unchecked field
      # @return [Boolean]                 Whether it doesn't exist
      #
      def has_no_unchecked_field?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:field, locator, options.merge(unchecked: true), &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a select field with the
      # given label, name or id.
      #
      # It can be specified which option should currently be selected:
      #
      #     page.has_select?('Language', selected: 'German')
      #
      # For multiple select boxes, several options may be specified:
      #
      #     page.has_select?('Language', selected: ['English', 'German'])
      #
      # It's also possible to check if the exact set of options exists for
      # this select box:
      #
      #     page.has_select?('Language', options: ['English', 'German', 'Spanish'])
      #
      # You can also check for a partial set of options:
      #
      #     page.has_select?('Language', with_options: ['English', 'German'])
      #
      # @param [String] locator                         The label, name or id of a select box
      # @option options [Array] :options                Options which should be contained in this select box
      # @option options [Array] :with_options           Partial set of options which should be contained in this select box
      # @option options [String, Array] :selected       Options which should be selected
      # @option options [String, Array] :with_selected  Partial set of options which should minimally be selected
      # @return [Boolean]                               Whether it exists
      #
      def has_select?(locator = nil, **options, &optional_filter_block)
        has_selector?(:select, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no select field with the
      # given label, name or id. See {#has_select?}.
      #
      # @param (see #has_select?)
      # @return [Boolean]     Whether it doesn't exist
      #
      def has_no_select?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:select, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has a table with the given id
      # or caption:
      #
      #    page.has_table?('People')
      #
      # @param [String] locator  The id or caption of a table
      # @option options [Array<Array<String>>] :rows
      #   Text which should be contained in the tables `<td>` elements organized by row (`<td>` visibility is not considered)
      # @option options [Array<Array<String>>, Array<Hash<String,String>>] :with_rows
      #   Partial set of text which should be contained in the tables `<td>` elements organized by row (`<td>` visibility is not considered)
      # @option options [Array<Array<String>>] :cols
      #   Text which should be contained in the tables `<td>` elements organized by column (`<td>` visibility is not considered)
      # @option options [Array<Array<String>>, Array<Hash<String,String>>] :with_cols
      #   Partial set of text which should be contained in the tables `<td>` elements organized by column (`<td>` visibility is not considered)
      # @return [Boolean]        Whether it exists
      #
      def has_table?(locator = nil, **options, &optional_filter_block)
        has_selector?(:table, locator, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the page or current node has no table with the given id
      # or caption. See {#has_table?}.
      #
      # @param (see #has_table?)
      # @return [Boolean]       Whether it doesn't exist
      #
      def has_no_table?(locator = nil, **options, &optional_filter_block)
        has_no_selector?(:table, locator, options, &optional_filter_block)
      end

      ##
      #
      # Asserts that the current node matches a given selector.
      #
      #     node.assert_matches_selector('p#foo')
      #     node.assert_matches_selector(:xpath, '//p[@id="foo"]')
      #     node.assert_matches_selector(:foo)
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as `:text` and `:visible`.
      #
      #     node.assert_matches_selector('li', text: 'Horse', visible: true)
      #
      # @param (see Capybara::Node::Finders#all)
      # @raise [Capybara::ExpectationNotMet]      If the selector does not match
      #
      def assert_matches_selector(*args, &optional_filter_block)
        _verify_match_result(args, optional_filter_block) do |result|
          raise Capybara::ExpectationNotMet, 'Item does not match the provided selector' unless result.include? self
        end
      end

      ##
      #
      # Asserts that the current node does not match a given selector.
      # Usage is identical to {#assert_matches_selector}.
      #
      # @param (see #assert_matches_selector)
      # @raise [Capybara::ExpectationNotMet]      If the selector matches
      #
      def assert_not_matches_selector(*args, &optional_filter_block)
        _verify_match_result(args, optional_filter_block) do |result|
          raise Capybara::ExpectationNotMet, 'Item matched the provided selector' if result.include? self
        end
      end

      ##
      #
      # Checks if the current node matches given selector.
      #
      # @param (see #has_selector?)
      # @return [Boolean]
      #
      def matches_selector?(*args, **options, &optional_filter_block)
        make_predicate(options) { assert_matches_selector(*args, options, &optional_filter_block) }
      end

      ##
      #
      # Checks if the current node matches given XPath expression.
      #
      # @param [String, XPath::Expression] xpath The XPath expression to match against the current code
      # @return [Boolean]
      #
      def matches_xpath?(xpath, **options, &optional_filter_block)
        matches_selector?(:xpath, xpath, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the current node matches given CSS selector.
      #
      # @param [String] css The CSS selector to match against the current code
      # @return [Boolean]
      #
      def matches_css?(css, **options, &optional_filter_block)
        matches_selector?(:css, css, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the current node does not match given selector.
      # Usage is identical to {#has_selector?}.
      #
      # @param (see #has_selector?)
      # @return [Boolean]
      #
      def not_matches_selector?(*args, **options, &optional_filter_block)
        make_predicate(options) { assert_not_matches_selector(*args, options, &optional_filter_block) }
      end

      ##
      #
      # Checks if the current node does not match given XPath expression.
      #
      # @param [String, XPath::Expression] xpath The XPath expression to match against the current code
      # @return [Boolean]
      #
      def not_matches_xpath?(xpath, **options, &optional_filter_block)
        not_matches_selector?(:xpath, xpath, options, &optional_filter_block)
      end

      ##
      #
      # Checks if the current node does not match given CSS selector.
      #
      # @param [String] css The CSS selector to match against the current code
      # @return [Boolean]
      #
      def not_matches_css?(css, **options, &optional_filter_block)
        not_matches_selector?(:css, css, options, &optional_filter_block)
      end

      ##
      # Asserts that the page or current node has the given text content,
      # ignoring any HTML tags.
      #
      # @!macro text_query_params
      #   @overload $0(type, text, **options)
      #     @param [:all, :visible] type               Whether to check for only visible or all text. If this parameter is missing or nil then we use the value of {Capybara.configure ignore_hidden_elements}, which defaults to `true`, corresponding to `:visible`.
      #     @param [String, Regexp] text               The string/regexp to check for. If it's a string, text is expected to include it. If it's a regexp, text is expected to match it.
      #     @option options [Integer] :count (nil)     Number of times the text is expected to occur
      #     @option options [Integer] :minimum (nil)   Minimum number of times the text is expected to occur
      #     @option options [Integer] :maximum (nil)   Maximum number of times the text is expected to occur
      #     @option options [Range]   :between (nil)   Range of times that is expected to contain number of times text occurs
      #     @option options [Numeric] :wait            Maximum time that Capybara will wait for text to eq/match given string/regexp argument. Defaults to {Capybara.configure default_max_wait_time}.
      #     @option options [Boolean] :exact           Whether text must be an exact match or just substring. Defaults to {Capybara.configure exact_text}.
      #     @option options [Boolean] :normalize_ws (false) When `true` replace all whitespace with standard spaces and collapse consecutive whitespace to a single space
      #   @overload $0(text, **options)
      #     @param [String, Regexp] text               The string/regexp to check for. If it's a string, text is expected to include it. If it's a regexp, text is expected to match it.
      #     @option options [Integer] :count (nil)     Number of times the text is expected to occur
      #     @option options [Integer] :minimum (nil)   Minimum number of times the text is expected to occur
      #     @option options [Integer] :maximum (nil)   Maximum number of times the text is expected to occur
      #     @option options [Range]   :between (nil)   Range of times that is expected to contain number of times text occurs
      #     @option options [Numeric] :wait            Maximum time that Capybara will wait for text to eq/match given string/regexp argument. Defaults to {Capybara.configure default_max_wait_time}.
      #     @option options [Boolean] :exact           Whether text must be an exact match or just substring. Defaults to {Capybara.configure exact_text}.
      #     @option options [Boolean] :normalize_ws (false) When `true` replace all whitespace with standard spaces and collapse consecutive whitespace to a single space
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_text(*args)
        _verify_text(args) do |count, query|
          unless query.matches_count?(count) && (count.positive? || query.expects_none?)
            raise Capybara::ExpectationNotMet, query.failure_message
          end
        end
      end

      ##
      # Asserts that the page or current node doesn't have the given text content,
      # ignoring any HTML tags.
      #
      # @macro text_query_params
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_no_text(*args)
        _verify_text(args) do |count, query|
          if query.matches_count?(count) && (count.positive? || query.expects_none?)
            raise Capybara::ExpectationNotMet, query.negative_failure_message
          end
        end
      end

      ##
      # Checks if the page or current node has the given text content,
      # ignoring any HTML tags.
      #
      # By default it will check if the text occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_text?('lorem ipsum', between: 2..4)
      #
      # This will check if the text occurs from 2 to 4 times.
      #
      # @macro text_query_params
      # @return [Boolean]                            Whether it exists
      #
      def has_text?(*args, **options)
        make_predicate(options) { assert_text(*args, options) }
      end
      alias_method :has_content?, :has_text?

      ##
      # Checks if the page or current node does not have the given text
      # content, ignoring any HTML tags and normalizing whitespace.
      #
      # @macro text_query_params
      # @return [Boolean]  Whether it doesn't exist
      #
      def has_no_text?(*args, **options)
        make_predicate(options) { assert_no_text(*args, options) }
      end
      alias_method :has_no_content?, :has_no_text?

      def ==(other)
        eql?(other) || (other.respond_to?(:base) && base == other.base)
      end

    private

      def extract_selector(args)
        args.first.is_a?(Symbol) ? args.shift : session_options.default_selector
      end

      def _verify_multiple(*args, wait: nil, **options)
        wait = session_options.default_max_wait_time if wait.nil?
        selector = extract_selector(args)
        synchronize(wait) do
          args.each { |locator| yield(selector, locator, options) }
        end
      end

      def _verify_selector_result(query_args, optional_filter_block)
        query_args = _set_query_session_options(*query_args)
        query = Capybara::Queries::SelectorQuery.new(*query_args, &optional_filter_block)
        synchronize(query.wait) do
          yield query.resolve_for(self), query
        end
        true
      end

      def _verify_match_result(query_args, optional_filter_block)
        query_args = _set_query_session_options(*query_args)
        query = Capybara::Queries::MatchQuery.new(*query_args, &optional_filter_block)
        synchronize(query.wait) do
          yield query.resolve_for(parent || session&.document || query_scope)
        end
        true
      end

      def _verify_text(query_args)
        query_args = _set_query_session_options(*query_args)
        query = Capybara::Queries::TextQuery.new(*query_args)
        synchronize(query.wait) do
          yield query.resolve_for(self), query
        end
        true
      end

      def _set_query_session_options(*query_args, **query_options)
        query_options[:session_options] = session_options
        query_args.push(query_options)
      end

      def make_predicate(options)
        options[:wait] = 0 unless options.key?(:wait) || session_options.predicates_wait
        yield
      rescue Capybara::ExpectationNotMet
        false
      end
    end
  end
end
