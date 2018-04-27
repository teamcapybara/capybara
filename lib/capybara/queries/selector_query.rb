# frozen_string_literal: true

module Capybara
  module Queries
    class SelectorQuery < Queries::BaseQuery
      attr_accessor :selector, :locator, :options, :expression, :find, :negative

      VALID_KEYS = COUNT_KEYS + %i[text id class visible exact exact_text match wait filter_set]
      VALID_MATCH = %i[first smart prefer_exact one].freeze

      def initialize(*args, session_options:, **options, &filter_block)
        @resolved_node = nil
        @options = options.dup
        super(@options)
        self.session_options = session_options

        @selector = find_selector(args[0].is_a?(Symbol) ? args.shift : args[0])
        @locator = args.shift
        @filter_block = filter_block

        raise ArgumentError, "Unused parameters passed to #{self.class.name} : #{args}" unless args.empty?

        @expression = @selector.call(@locator, @options.merge(enable_aria_label: session_options.enable_aria_label))

        warn_exact_usage

        assert_valid_keys
      end

      def name; selector.name; end
      def label; selector.label || selector.name; end

      def description
        @description = "".dup
        @description << "visible " if visible == :visible
        @description << "non-visible " if visible == :hidden
        @description << "#{label} #{locator.inspect}"
        @description << " with#{' exact' if exact_text == true} text #{options[:text].inspect}" if options[:text]
        @description << " with exact text #{options[:exact_text]}" if options[:exact_text].is_a?(String)
        @description << " with id #{options[:id]}" if options[:id]
        @description << " with classes [#{Array(options[:class]).join(',')}]" if options[:class]
        @description << selector.description(options)
        @description << " that also matches the custom filter block" if @filter_block
        @description << " within #{@resolved_node.inspect}" if describe_within?
        @description
      end

      def matches_filters?(node)
        return false if options[:text] && !matches_text_filter(node, options[:text])
        return false if exact_text.is_a?(String) && !matches_exact_text_filter(node, exact_text)

        case visible
        when :visible then return false unless node.visible?
        when :hidden then return false if node.visible?
        end

        matches_node_filters?(node) && matches_filter_block?(node)
      rescue *(node.respond_to?(:session) ? node.session.driver.invalid_element_errors : [])
        return false
      end

      def visible
        case (vis = options.fetch(:visible) { @selector.default_visibility(session_options.ignore_hidden_elements) })
        when true then :visible
        when false then :all
        else vis
        end
      end

      def exact?
        supports_exact? ? options.fetch(:exact, session_options.exact) : false
      end

      def match
        options.fetch(:match, session_options.match)
      end

      def xpath(exact = nil)
        exact = exact? if exact.nil?
        expr = apply_expression_filters(@expression)
        expr = exact ? expr.to_xpath(:exact) : expr.to_s if expr.respond_to?(:to_xpath)
        filtered_xpath(expr)
      end

      def css
        filtered_css(apply_expression_filters(@expression))
      end

      # @api private
      def resolve_for(node, exact = nil)
        @resolved_node = node
        node.synchronize do
          children = if selector.format == :css
            node.find_css(css)
          else
            node.find_xpath(xpath(exact))
          end.map do |child|
            if node.is_a?(Capybara::Node::Base)
              Capybara::Node::Element.new(node.session, child, node, self)
            else
              Capybara::Node::Simple.new(child)
            end
          end
          Capybara::Result.new(children, self)
        end
      end

      # @api private
      def supports_exact?
        @expression.respond_to? :to_xpath
      end

    private

      def find_selector(locator)
        selector = if locator.is_a?(Symbol)
          Selector.all.fetch(locator) { |sel_type| raise ArgumentError, "Unknown selector type (:#{sel_type})" }
        else
          Selector.all.values.find { |s| s.match?(locator) }
        end
        selector || Selector.all[session_options.default_selector]
      end

      def valid_keys
        VALID_KEYS + custom_keys
      end

      def matches_node_filters?(node)
        node_filters.all? do |name, filter|
          if options.key?(name)
            filter.matches?(node, options[name])
          elsif filter.default?
            filter.matches?(node, filter.default)
          else
            true
          end
        end
      end

      def matches_filter_block?(node)
        return true unless @filter_block

        if node.respond_to?(:session)
          node.session.using_wait_time(0) { @filter_block.call(node) }
        else
          @filter_block.call(node)
        end
      end

      def node_filters
        if options.key?(:filter_set)
          ::Capybara::Selector::FilterSet.all[options[:filter_set]].node_filters
        else
          @selector.node_filters
        end
      end

      def expression_filters
        filters = @selector.expression_filters
        filters.merge ::Capybara::Selector::FilterSet.all[options[:filter_set]].expression_filters if options.key?(:filter_set)
        filters
      end

      def custom_keys
        @custom_keys ||= node_filters.keys + expression_filters.keys
      end

      def assert_valid_keys
        super
        return if VALID_MATCH.include?(match)
        raise ArgumentError, "invalid option #{match.inspect} for :match, should be one of #{VALID_MATCH.map(&:inspect).join(', ')}"
      end

      def filtered_xpath(expr)
        if options.key?(:id) || options.key?(:class)
          expr = "(#{expr})"
          expr = "#{expr}[#{XPath.attr(:id) == options[:id]}]" if options.key?(:id) && !custom_keys.include?(:id)
          if options.key?(:class) && !custom_keys.include?(:class)
            class_xpath = Array(options[:class]).map do |klass|
              XPath.attr(:class).contains_word(klass)
            end.reduce(:&)
            expr = "#{expr}[#{class_xpath}]"
          end
        end
        expr
      end

      def filtered_css(expr)
        if options.key?(:id) || options.key?(:class)
          css_selectors = expr.split(',').map(&:rstrip)
          expr = css_selectors.map do |sel|
            sel += "##{Capybara::Selector::CSS.escape(options[:id])}" if options.key?(:id) && !custom_keys.include?(:id)
            sel += Array(options[:class]).map { |k| ".#{Capybara::Selector::CSS.escape(k)}" }.join if options.key?(:class) && !custom_keys.include?(:class)
            sel
          end.join(", ")
        end
        expr
      end

      def apply_expression_filters(expr)
        expression_filters.inject(expr) do |memo, (name, ef)|
          if options.key?(name)
            ef.apply_filter(memo, options[name])
          elsif ef.default?
            ef.apply_filter(memo, ef.default)
          else
            memo
          end
        end
      end

      def warn_exact_usage
        return unless options.key?(:exact) && !supports_exact?
        warn "The :exact option only has an effect on queries using the XPath#is method. Using it with the query \"#{expression}\" has no effect."
      end

      def exact_text
        options.fetch(:exact_text, session_options.exact_text)
      end

      def describe_within?
        @resolved_node && !(@resolved_node.is_a?(::Capybara::Node::Document) ||
                            (@resolved_node.is_a?(::Capybara::Node::Simple) && @resolved_node.path == '/'))
      end

      def matches_text_filter(node, text_option)
        regexp = if text_option.is_a?(Regexp)
          text_option
        elsif exact_text == true
          /\A#{Regexp.escape(text_option.to_s)}\z/
        else
          Regexp.escape(text_option.to_s)
        end
        text_visible = visible
        text_visible = :all if text_visible == :hidden
        node.text(text_visible).match(regexp)
      end

      def matches_exact_text_filter(node, exact_text_option)
        regexp = /\A#{Regexp.escape(exact_text_option)}\z/
        text_visible = visible
        text_visible = :all if text_visible == :hidden
        node.text(text_visible).match(regexp)
      end
    end
  end
end
