# frozen_string_literal: true

# rubocop:disable Style/AsciiComments

require 'capybara/selector/filter_set'
require 'capybara/selector/css'

module Capybara
  #
  # ## Built-in Selectors
  #
  #   * **:xpath** - Select elements by XPath expression
  #     * Locator: An XPath expression
  #
  #   * **:css** - Select elements by CSS selector
  #     * Locator: A CSS selector
  #
  #   * **:id** - Select element by id
  #     * Locator: The id of the element to match
  #
  #   * **:field** - Select field elements (input [not of type submit, image, or hidden], textarea, select)
  #     * Locator: Matches against the id, Capybara.test_id attribute, name, or placeholder
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :name (String) — Matches the name attribute
  #       * :placeholder (String) — Matches the placeholder attribute
  #       * :type (String) — Matches the type attribute of the field or element type for 'textarea' and 'select'
  #       * :readonly (Boolean)
  #       * :with (String) — Matches the current value of the field
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #       * :checked (Boolean) — Match checked fields?
  #       * :unchecked (Boolean) — Match unchecked fields?
  #       * :disabled (Boolean) — Match disabled field?
  #       * :multiple (Boolean) — Match fields that accept multiple values
  #
  #   * **:fieldset** - Select fieldset elements
  #     * Locator: Matches id or contents of wrapped legend
  #     * Filters:
  #       * :id (String) — Matches id attribute
  #       * :legend (String) — Matches contents of wrapped legend
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #
  #   * **:link** - Find links ( <a> elements with an href attribute )
  #     * Locator: Matches the id or title attributes, or the string content of the link, or the alt attribute of a contained img element
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :title (String) — Matches the title attribute
  #       * :alt (String) — Matches the alt attribute of a contained img element
  #       * :class (String) — Matches the class(es) provided
  #       * :href (String, Regexp, nil) — Matches the normalized href of the link, if nil will find <a> elements with no href attribute
  #
  #   * **:button** - Find buttons ( input [of type submit, reset, image, button] or button elements )
  #     * Locator: Matches the id, Capybara.test_id attribute, value, or title attributes, string content of a button, or the alt attribute of an image type button or of a descendant image of a button
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :title (String) — Matches the title attribute
  #       * :class (String) — Matches the class(es) provided
  #       * :value (String) — Matches the value of an input button
  #       * :type
  #
  #   * **:link_or_button** - Find links or buttons
  #     * Locator: See :link and :button selectors
  #
  #   * **:fillable_field** - Find text fillable fields ( textarea, input [not of type submit, image, radio, checkbox, hidden, file] )
  #     * Locator: Matches against the id, Capybara.test_id attribute, name, or placeholder
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :name (String) — Matches the name attribute
  #       * :placeholder (String) — Matches the placeholder attribute
  #       * :with (String) — Matches the current value of the field
  #       * :type (String) — Matches the type attribute of the field or element type for 'textarea'
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #       * :disabled (Boolean) — Match disabled field?
  #       * :multiple (Boolean) — Match fields that accept multiple values
  #
  #   * **:radio_button** - Find radio buttons
  #     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :name (String) — Matches the name attribute
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #       * :checked (Boolean) — Match checked fields?
  #       * :unchecked (Boolean) — Match unchecked fields?
  #       * :disabled (Boolean) — Match disabled field?
  #       * :option (String) — Match the value
  #
  #   * **:checkbox** - Find checkboxes
  #     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
  #     * Filters:
  #       * *:id (String) — Matches the id attribute
  #       * *:name (String) — Matches the name attribute
  #       * *:class (String, Array<String>) — Matches the class(es) provided
  #       * *:checked (Boolean) — Match checked fields?
  #       * *:unchecked (Boolean) — Match unchecked fields?
  #       * *:disabled (Boolean) — Match disabled field?
  #       * *:option (String) — Match the value
  #
  #   * **:select** - Find select elements
  #     * Locator: Match id, Capybara.test_id attribute, name, placeholder, or associated label text
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :name (String) — Matches the name attribute
  #       * :placeholder (String) — Matches the placeholder attribute
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #       * :disabled (Boolean) — Match disabled field?
  #       * :multiple (Boolean) — Match fields that accept multiple values
  #       * :options (Array<String>) — Exact match options
  #       * :with_options (Array<String>) — Partial match options
  #       * :selected (String, Array<String>) — Match the selection(s)
  #       * :with_selected (String, Array<String>) — Partial match the selection(s)
  #
  #   * **:option** - Find option elements
  #     * Locator: Match text of option
  #     * Filters:
  #       * :disabled (Boolean) — Match disabled option
  #       * :selected (Boolean) — Match selected option
  #
  #   * **:datalist_input**
  #     * Locator:
  #     * Filters:
  #       * :disabled
  #       * :name
  #       * :placeholder
  #
  #   * **:datalist_option**
  #     * Locator:
  #
  #   * **:file_field** - Find file input elements
  #     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
  #     * Filters:
  #       * :id (String) — Matches the id attribute
  #       * :name (String) — Matches the name attribute
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #       * :disabled (Boolean) — Match disabled field?
  #       * :multiple (Boolean) — Match field that accepts multiple values
  #
  #   * **:label** - Find label elements
  #     * Locator: Match id or text contents
  #     * Filters:
  #       * :for (Element, String) — The element or id of the element associated with the label
  #
  #   * **:table** - Find table elements
  #     * Locator: id or caption text of table
  #     * Filters:
  #       * :id (String) — Match id attribute of table
  #       * :caption (String) — Match text of associated caption
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #
  #   * **:frame** - Find frame/iframe elements
  #     * Locator: Match id or name
  #     * Filters:
  #       * :id (String) — Match id attribute
  #       * :name (String) — Match name attribute
  #       * :class (String, Array<String>) — Matches the class(es) provided
  #
  #   * **:element**
  #     * Locator: Type of element ('div', 'a', etc) - if not specified defaults to '*'
  #     * Filters: Matches on any element attribute
  #
  class Selector
    attr_reader :name, :format
    extend Forwardable

    class << self
      def all
        @selectors ||= {} # rubocop:disable Naming/MemoizedInstanceVariableName
      end

      def add(name, &block)
        all[name.to_sym] = Capybara::Selector.new(name.to_sym, &block)
      end

      def update(name, &block)
        all[name.to_sym].instance_eval(&block)
      end

      def remove(name)
        all.delete(name.to_sym)
      end
    end

    def initialize(name, &block)
      @name = name
      @filter_set = FilterSet.add(name) {}
      @match = nil
      @label = nil
      @failure_message = nil
      @format = nil
      @expression = nil
      @expression_filters = {}
      @default_visibility = nil
      @config = {
        enable_aria_label: false,
        test_id: nil
      }
      instance_eval(&block)
    end

    def custom_filters
      warn "Deprecated: Selector#custom_filters is not valid when same named expression and node filter exist - don't use"
      node_filters.merge(expression_filters).freeze
    end

    def node_filters
      @filter_set.node_filters
    end

    def expression_filters
      @filter_set.expression_filters
    end

    ##
    #
    # Define a selector by an xpath expression
    #
    # @overload xpath(*expression_filters, &block)
    #   @param [Array<Symbol>] expression_filters ([])  Names of filters that can be implemented via this expression
    #   @yield [locator, options]                       The block to use to generate the XPath expression
    #   @yieldparam [String] locator                    The locator string passed to the query
    #   @yieldparam [Hash] options                      The options hash passed to the query
    #   @yieldreturn [#to_xpath, #to_s]                 An object that can produce an xpath expression
    #
    # @overload xpath()
    # @return [#call]                             The block that will be called to generate the XPath expression
    #
    def xpath(*allowed_filters, &block)
      if block
        @format, @expression = :xpath, block
        allowed_filters.flatten.each { |ef| expression_filters[ef] = Filters::IdentityExpressionFilter.new(ef) }
      end
      format == :xpath ? @expression : nil
    end

    ##
    #
    # Define a selector by a CSS selector
    #
    # @overload css(*expression_filters, &block)
    #   @param [Array<Symbol>] expression_filters ([])  Names of filters that can be implemented via this CSS selector
    #   @yield [locator, options]                   The block to use to generate the CSS selector
    #   @yieldparam [String] locator               The locator string passed to the query
    #   @yieldparam [Hash] options                 The options hash passed to the query
    #   @yieldreturn [#to_s]                        An object that can produce a CSS selector
    #
    # @overload css()
    # @return [#call]                             The block that will be called to generate the CSS selector
    #
    def css(*allowed_filters, &block)
      if block
        @format, @expression = :css, block
        allowed_filters.flatten.each { |ef| expression_filters[ef] = nil }
      end
      format == :css ? @expression : nil
    end

    ##
    #
    # Automatic selector detection
    #
    # @yield [locator]                   This block takes the passed in locator string and returns whether or not it matches the selector
    # @yieldparam [String], locator      The locator string used to determin if it matches the selector
    # @yieldreturn [Boolean]             Whether this selector matches the locator string
    # @return [#call]                    The block that will be used to detect selector match
    #
    def match(&block)
      @match = block if block
      @match
    end

    ##
    #
    # Set/get a descriptive label for the selector
    #
    # @overload label(label)
    #   @param [String] label            A descriptive label for this selector - used in error messages
    # @overload label()
    # @return [String]                 The currently set label
    #
    def label(label = nil)
      @label = label if label
      @label
    end

    ##
    #
    # Description of the selector
    #
    # @!method description(options)
    #   @param [Hash] options            The options of the query used to generate the description
    #   @return [String]                 Description of the selector when used with the options passed
    def_delegator :@filter_set, :description

    def call(locator, selector_config: {}, **options)
      @config.merge! selector_config
      if format
        @expression.call(locator, options)
      else
        warn 'Selector has no format'
      end
    end

    ##
    #
    #  Should this selector be used for the passed in locator
    #
    #  This is used by the automatic selector selection mechanism when no selector type is passed to a selector query
    #
    # @param [String] locator     The locator passed to the query
    # @return [Boolean]           Whether or not to use this selector
    #
    def match?(locator)
      @match&.call(locator)
    end

    ##
    #
    # Define a node filter for use with this selector
    #
    # @!method node_filter(name, *types, options={}, &block)
    #   @param [Symbol, Regexp] name            The filter name
    #   @param [Array<Symbol>] types    The types of the filter - currently valid types are [:boolean]
    #   @param [Hash] options ({})      Options of the filter
    #   @option options [Array<>] :valid_values Valid values for this filter
    #   @option options :default        The default value of the filter (if any)
    #   @option options :skip_if        Value of the filter that will cause it to be skipped
    #   @option options [Regexp] :matcher (nil) A Regexp used to check whether a specific option is handled by this filter.  If not provided the filter will be used for options matching the filter name.
    #
    # If a Symbol is passed for the name the block should accept | node, option_value |, while if a Regexp
    # is passed for the name the block should accept | node, option_name, option_value |. In either case
    # the block should return `true` if the node passes the filer or `false` if it doesn't

    # @!method filter
    #   See {Selector#node_filter}

    ##
    #
    # Define an expression filter for use with this selector
    #
    # @!method expression_filter(name, *types, matcher: nil, **options, &block)
    #   @param [Symbol, Regexp] name            The filter name
    #   @param [Regexp] matcher (nil)   A Regexp used to check whether a specific option is handled by this filter
    #   @param [Array<Symbol>] types    The types of the filter - currently valid types are [:boolean]
    #   @param [Hash] options ({})      Options of the filter
    #   @option options [Array<>] :valid_values Valid values for this filter
    #   @option options :default        The default value of the filter (if any)
    #   @option options :skip_if        Value of the filter that will cause it to be skipped
    #   @option options [Regexp] :matcher (nil) A Regexp used to check whether a specific option is handled by this filter.  If not provided the filter will be used for options matching the filter name.
    #
    # If a Symbol is passed for the name the block should accept | current_expression, option_value |, while if a Regexp
    # is passed for the name the block should accept | current_expression, option_name, option_value |. In either case
    # the block should return the modified expression

    def_delegators :@filter_set, :node_filter, :expression_filter, :filter

    def filter_set(name, filters_to_use = nil)
      @filter_set.import(name, filters_to_use)
    end

    def_delegator :@filter_set, :describe

    def describe_expression_filters(&block)
      if block_given?
        describe(:expression_filters, &block)
      else
        describe(:expression_filters) do |**options|
          describe_all_expression_filters(options)
        end
      end
    end

    def describe_node_filters(&block)
      describe(:node_filters, &block)
    end

    ##
    #
    # Set the default visibility mode that shouble be used if no visibile option is passed when using the selector.
    # If not specified will default to the behavior indicated by Capybara.ignore_hidden_elements
    #
    # @param [Symbol] default_visibility  Only find elements with the specified visibility:
    #                                              * :all - finds visible and invisible elements.
    #                                              * :hidden - only finds invisible elements.
    #                                              * :visible - only finds visible elements.
    def visible(default_visibility)
      @default_visibility = default_visibility
    end

    def default_visibility(fallback = Capybara.ignore_hidden_elements)
      return @default_visibility unless @default_visibility.nil?
      fallback
    end

  private

    def enable_aria_label
      @config[:enable_aria_label]
    end

    def test_id
      @config[:test_id]
    end

    def locate_field(xpath, locator, **_options)
      return xpath if locator.nil?
      locate_xpath = xpath # Need to save original xpath for the label wrap
      locator = locator.to_s
      attr_matchers = [XPath.attr(:id) == locator,
                       XPath.attr(:name) == locator,
                       XPath.attr(:placeholder) == locator,
                       XPath.attr(:id) == XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for)].reduce(:|)
      attr_matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label
      attr_matchers |= XPath.attr(test_id) == locator if test_id

      locate_xpath = locate_xpath[attr_matchers]
      locate_xpath + XPath.descendant(:label)[XPath.string.n.is(locator)].descendant(xpath)
    end

    def describe_all_expression_filters(**opts)
      expression_filters.map do |ef_name, ef|
        if ef.matcher?
          opts.keys.map do |key|
            " with #{ef_name}[#{key} => #{opts[key]}]" if ef.handles_option?(key) && !::Capybara::Queries::SelectorQuery::VALID_KEYS.include?(key)
          end.join
        elsif opts.key?(ef_name)
          " with #{ef_name} #{opts[ef_name]}"
        end
      end.join
    end

    def find_by_attr(attribute, value)
      finder_name = "find_by_#{attribute}_attr"
      if respond_to?(finder_name, true)
        send(finder_name, value)
      else
        value ? XPath.attr(attribute) == value : nil
      end
    end

    def find_by_class_attr(classes)
      Array(classes).map { |klass| XPath.attr(:class).contains_word(klass) }.reduce(:&)
    end
  end
end

# rubocop:enable Style/AsciiComments
