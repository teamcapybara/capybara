# frozen_string_literal: true

module Capybara
  module Queries
    class SelectorQuery < Queries::BaseQuery
      attr_reader :expression, :selector, :locator, :options
      VALID_KEYS = COUNT_KEYS + %i[text id class visible exact exact_text normalize_ws match wait filter_set]
      VALID_MATCH = %i[first smart prefer_exact one].freeze

      def initialize(*args,
                     session_options:,
                     enable_aria_label: session_options.enable_aria_label,
                     test_id: session_options.test_id,
                     **options,
                     &filter_block)
        @resolved_node = nil
        @options = options.dup
        super(@options)
        self.session_options = session_options

        @selector = find_selector(args[0].is_a?(Symbol) ? args.shift : args[0])
        @locator = args.shift
        @filter_block = filter_block

        raise ArgumentError, "Unused parameters passed to #{self.class.name} : #{args}" unless args.empty?

        @expression = selector.call(@locator, @options.merge(selector_config: { enable_aria_label: enable_aria_label, test_id: test_id }))

        warn_exact_usage

        assert_valid_keys
      end

      def name; selector.name; end
      def label; selector.label || selector.name; end

      def description(applied = false)
        desc = +''
        if !applied || applied_filters
          desc << 'visible ' if visible == :visible
          desc << 'non-visible ' if visible == :hidden
        end
        desc << "#{label} #{locator.inspect}"
        if !applied || applied_filters
          desc << " with#{' exact' if exact_text == true} text #{options[:text].inspect}" if options[:text]
          desc << " with exact text #{exact_text}" if exact_text.is_a?(String)
        end
        desc << " with id #{options[:id]}" if options[:id]
        desc << " with classes [#{Array(options[:class]).join(',')}]" if options[:class]
        desc << selector.description(node_filters: !applied || (applied_filters == :node), **options)
        desc << ' that also matches the custom filter block' if @filter_block && (!applied || (applied_filters == :node))
        desc << " within #{@resolved_node.inspect}" if describe_within?
        desc
      end

      def applied_description
        description(true)
      end

      def matches_filters?(node)
        return true if (@resolved_node&.== node) && options[:allow_self]

        @applied_filters ||= :system
        return false unless matches_system_filters?(node)

        @applied_filters = :node
        matches_node_filters?(node) && matches_filter_block?(node)
      rescue *(node.respond_to?(:session) ? node.session.driver.invalid_element_errors : [])
        false
      end

      def visible
        case (vis = options.fetch(:visible) { @selector.default_visibility(session_options.ignore_hidden_elements, options) })
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
        @applied_filters = false
        @resolved_node = node
        node.synchronize do
          children = find_nodes_by_selector_format(node, exact).map(&method(:to_element))
          Capybara::Result.new(children, self)
        end
      end

      # @api private
      def supports_exact?
        @expression.respond_to? :to_xpath
      end

      def failure_message
        +"expected to find #{applied_description}" << count_message
      end

      def negative_failure_message
        +"expected not to find #{applied_description}" << count_message
      end

    private

      def applied_filters
        @applied_filters ||= false
      end

      def find_selector(locator)
        selector = if locator.is_a?(Symbol)
          Selector.all.fetch(locator) { |sel_type| raise ArgumentError, "Unknown selector type (:#{sel_type})" }
        else
          Selector.all.values.find { |sel| sel.match?(locator) }
        end
        selector || Selector.all[session_options.default_selector]
      end

      def find_nodes_by_selector_format(node, exact)
        if selector.format == :css
          node.find_css(css)
        else
          node.find_xpath(xpath(exact))
        end
      end

      def to_element(node)
        if @resolved_node.is_a?(Capybara::Node::Base)
          Capybara::Node::Element.new(@resolved_node.session, node, @resolved_node, self)
        else
          Capybara::Node::Simple.new(node)
        end
      end

      def valid_keys
        VALID_KEYS + custom_keys
      end

      def matches_node_filters?(node)
        unapplied_options = options.keys - valid_keys
        node_filters.all? do |filter_name, filter|
          if filter.matcher?
            unapplied_options.select { |option_name| filter.handles_option?(option_name) }.all? do |option_name|
              unapplied_options.delete(option_name)
              filter.matches?(node, option_name, options[option_name])
            end
          elsif options.key?(filter_name)
            unapplied_options.delete(filter_name)
            filter.matches?(node, filter_name, options[filter_name])
          elsif filter.default?
            filter.matches?(node, filter_name, filter.default)
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
        unless VALID_MATCH.include?(match)
          raise ArgumentError, "invalid option #{match.inspect} for :match, should be one of #{VALID_MATCH.map(&:inspect).join(', ')}"
        end

        unhandled_options = @options.keys.reject do |option_name|
          valid_keys.include?(option_name) ||
            expression_filters.any? { |_name, ef| ef.handles_option? option_name } ||
            node_filters.any? { |_name, nf| nf.handles_option? option_name }
        end

        return if unhandled_options.empty?

        invalid_names = unhandled_options.map(&:inspect).join(', ')
        valid_names = (valid_keys - [:allow_self]).map(&:inspect).join(', ')
        raise ArgumentError, "invalid keys #{invalid_names}, should be one of #{valid_names}"
      end

      def filtered_xpath(expr)
        expr = "(#{expr})[#{conditions_from_id}]" if use_default_id_filter?
        expr = "(#{expr})[#{conditions_from_classes}]" if use_default_class_filter?
        expr
      end

      def filtered_css(expr)
        ::Capybara::Selector::CSS.split(expr).map do |sel|
          sel += conditions_from_id if use_default_id_filter?
          sel += conditions_from_classes if use_default_class_filter?
          sel
        end.join(', ')
      end

      def use_default_id_filter?
        options.key?(:id) && !custom_keys.include?(:id)
      end

      def use_default_class_filter?
        options.key?(:class) && !custom_keys.include?(:class)
      end

      def conditions_from_classes
        builder.class_conditions(options[:class])
      end

      def conditions_from_id
        builder.attribute_conditions(id: options[:id])
      end

      def apply_expression_filters(expression)
        unapplied_options = options.keys - valid_keys
        expression_filters.inject(expression) do |expr, (name, ef)|
          if ef.matcher?
            unapplied_options.select { |option_name| ef.handles_option?(option_name) }.inject(expr) do |memo, option_name|
              unapplied_options.delete(option_name)
              ef.apply_filter(memo, option_name, options[option_name])
            end
          elsif options.key?(name)
            unapplied_options.delete(name)
            ef.apply_filter(expr, name, options[name])
          elsif ef.default?
            ef.apply_filter(expr, name, ef.default)
          else
            expr
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
        @resolved_node && !document?(@resolved_node) && !simple_root?(@resolved_node)
      end

      def document?(node)
        node.is_a?(::Capybara::Node::Document)
      end

      def simple_root?(node)
        node.is_a?(::Capybara::Node::Simple) && node.path == '/'
      end

      def matches_system_filters?(node)
        matches_id_filter?(node) &&
          matches_class_filter?(node) &&
          matches_text_filter?(node) &&
          matches_exact_text_filter?(node) &&
          matches_visible_filter?(node)
      end

      def matches_id_filter?(node)
        return true unless use_default_id_filter? && options[:id].is_a?(Regexp)

        node[:id] =~ options[:id]
      end

      def matches_class_filter?(node)
        return true unless use_default_class_filter? && options[:class].is_a?(Regexp)

        node[:class] =~ options[:class]
      end

      def matches_text_filter?(node)
        value = options[:text]
        return true unless value
        return matches_text_exactly?(node, value) if exact_text == true

        regexp = value.is_a?(Regexp) ? value : Regexp.escape(value.to_s)
        matches_text_regexp?(node, regexp)
      end

      def matches_exact_text_filter?(node)
        return true unless exact_text.is_a?(String)

        matches_text_exactly?(node, exact_text)
      end

      def matches_visible_filter?(node)
        case visible
        when :visible then node.visible?
        when :hidden then !node.visible?
        else true
        end
      end

      def matches_text_exactly?(node, value)
        regexp = value.is_a?(Regexp) ? value : /\A#{Regexp.escape(value.to_s)}\z/
        matches_text_regexp?(node, regexp)
      end

      def normalize_ws
        options.fetch(:normalize_ws, session_options.default_normalize_ws)
      end

      def matches_text_regexp?(node, regexp)
        text_visible = visible
        text_visible = :all if text_visible == :hidden
        !!node.text(text_visible, normalize_ws: normalize_ws).match(regexp)
      end

      def builder
        selector.builder
      end
    end
  end
end
