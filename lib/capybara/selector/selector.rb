# frozen_string_literal: true

require 'capybara/selector/filter_set'
require 'capybara/selector/css'
require 'xpath'

# Patch XPath to allow a nil condition in where
module XPath
  class Renderer
    undef :where if method_defined?(:where)
    def where(on, condition)
      condition = condition.to_s
      if !condition.empty?
        "#{on}[#{condition}]"
      else
        on.to_s
      end
    end
  end
end

module Capybara
  class Selector
    attr_reader :name, :format

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
      @description = nil
      @format = nil
      @expression = nil
      @expression_filters = {}
      @default_visibility = nil
      instance_eval(&block)
    end

    def custom_filters
      @filter_set.filters
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
    def xpath(*expression_filters, &block)
      if block
        @format, @expression = :xpath, block
        expression_filters.flatten.each { |ef| custom_filters[ef] = Filters::IdentityExpressionFilter.new }
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
    def css(*expression_filters, &block)
      if block
        @format, @expression = :css, block
        expression_filters.flatten.each { |ef| custom_filters[ef] = nil }
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
    # @param [Hash] options            The options of the query used to generate the description
    # @return [String]                 Description of the selector when used with the options passed
    #
    def description(**options)
      @filter_set.description(options)
    end

    def call(locator, **options)
      if format
        @expression.call(locator, options)
      else
        warn "Selector has no format"
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
      @match and @match.call(locator)
    end

    ##
    #
    # Define a non-expression filter for use with this selector
    #
    # @overload filter(name, *types, options={}, &block)
    #   @param [Symbol] name            The filter name
    #   @param [Array<Symbol>] types    The types of the filter - currently valid types are [:boolean]
    #   @param [Hash] options ({})      Options of the filter
    #   @option options [Array<>] :valid_values Valid values for this filter
    #   @option options :default        The default value of the filter (if any)
    #   @option options :skip_if        Value of the filter that will cause it to be skipped
    #
    def filter(name, *types_and_options, &block)
      add_filter(name, Filters::NodeFilter, *types_and_options, &block)
    end

    def expression_filter(name, *types_and_options, &block)
      add_filter(name, Filters::ExpressionFilter, *types_and_options, &block)
    end

    def filter_set(name, filters_to_use = nil)
      f_set = FilterSet.all[name]
      f_set.filters.each do |n, filter|
        custom_filters[n] = filter if filters_to_use.nil? || filters_to_use.include?(n)
      end

      f_set.descriptions.each { |desc| @filter_set.describe(&desc) }
    end

    def describe(&block)
      @filter_set.describe(&block)
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
      if @default_visibility.nil?
        fallback
      else
        @default_visibility
      end
    end

  private

    def add_filter(name, filter_class, *types, **options, &block)
      types.each { |k| options[k] = true }
      custom_filters[name] = filter_class.new(name, block, options)
    end

    def locate_field(xpath, locator, enable_aria_label: false, **_options)
      locate_xpath = xpath # Need to save original xpath for the label wrap
      if locator
        locator = locator.to_s
        attr_matchers = [XPath.attr(:id) == locator,
                         XPath.attr(:name) == locator,
                         XPath.attr(:placeholder) == locator,
                         XPath.attr(:id) == XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for)].reduce(:|)
        attr_matchers |= XPath.attr(:'aria-label').is(locator) if enable_aria_label

        locate_xpath = locate_xpath[attr_matchers]
        locate_xpath = locate_xpath.union(XPath.descendant(:label)[XPath.string.n.is(locator)].descendant(xpath))
      end

      # locate_xpath = [:name, :placeholder].inject(locate_xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }
      locate_xpath
    end

    def describe_all_expression_filters(**opts)
      expression_filters.keys.map { |ef| " with #{ef} #{opts[ef]}" if opts.key?(ef) }.join
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
