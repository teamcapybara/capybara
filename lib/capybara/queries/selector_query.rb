# frozen_string_literal: true
module Capybara
  module Queries
    class SelectorQuery < Queries::BaseQuery
      attr_accessor :selector, :locator, :options, :expression, :find, :negative

      VALID_KEYS = COUNT_KEYS + [:text, :id, :class, :visible, :exact, :match, :wait, :filter_set]
      VALID_MATCH = [:first, :last, :smart, :prefer_exact, :one]

      def initialize(*args, &filter_block)
        @options = if args.last.is_a?(Hash) then args.pop.dup else {} end
        @filter_block = filter_block

        if args[0].is_a?(Symbol)
          @selector = Selector.all.fetch(args.shift) do |selector_type|
            warn "Unknown selector type (:#{selector_type}), defaulting to :#{Capybara.default_selector} - This will raise an exception in a future version of Capybara"
            nil
          end
          @locator = args.shift
        else
          @selector = Selector.all.values.find { |s| s.match?(args[0]) }
          @locator = args.shift
        end
        @selector ||= Selector.all[Capybara.default_selector]

        warn "Unused parameters passed to #{self.class.name} : #{args.to_s}" unless args.empty?

        # for compatibility with Capybara 2.0
        if Capybara.exact_options and @selector == Selector.all[:option]
          @options[:exact] = true
        end

        @expression = @selector.call(@locator, @options)

        warn_exact_usage

        assert_valid_keys
      end

      def name; selector.name; end
      def label; selector.label or selector.name; end

      def description
        @description = String.new("#{label} #{locator.inspect}")
        @description << " with text #{options[:text].inspect}" if options[:text]
        @description << " with id #{options[:id]}" if options[:id]
        @description << " with classes #{Array(options[:class]).join(',')}]" if options[:class]
        @description << selector.description(options)
        @description << " that also matches the custom filter block" if @filter_block
        @description
      end

      def matches_filters?(node)
        if options[:text]
          regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text].to_s)
          text_visible = visible
          text_visible = :all if text_visible == :hidden
          return false if not node.text(text_visible).match(regexp)
        end

        case visible
          when :visible then return false unless node.visible?
          when :hidden then return false if node.visible?
        end

        res = query_filters.all? do |name, filter|
          if options.has_key?(name)
            filter.matches?(node, options[name])
          elsif filter.default?
            filter.matches?(node, filter.default)
          else
            true
          end
        end

        res &&= Capybara.using_wait_time(0){ @filter_block.call(node)} unless @filter_block.nil?
        res
      end

      def visible
        case (vis = options.fetch(:visible){ @selector.default_visibility })
          when true then :visible
          when false then :all
          else vis
        end
      end

      def exact?
        return false if !supports_exact?
        options.fetch(:exact, Capybara.exact)
      end

      def match
        options.fetch(:match, Capybara.match)
      end

      def xpath(exact=nil)
        exact = self.exact? if exact.nil?
        expr = if @expression.respond_to?(:to_xpath) and exact
          @expression.to_xpath(:exact)
        else
          @expression.to_s
        end
        filtered_xpath(expr)
      end

      def css
        filtered_css(@expression)
      end

      # @api private
      def resolve_for(node, exact = nil)
        node.synchronize do
          children = if selector.format == :css
            node.find_css(self.css)
          else
            node.find_xpath(self.xpath(exact))
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

      def valid_keys
        VALID_KEYS + custom_keys
      end

      def query_filters
        if options.has_key?(:filter_set)
          Capybara::Selector::FilterSet.all[options[:filter_set]].filters
        else
          @selector.custom_filters
        end
      end

      def custom_keys
        @custom_keys ||= query_filters.keys + @selector.expression_filters
      end

      def assert_valid_keys
        super
        unless VALID_MATCH.include?(match)
          raise ArgumentError, "invalid option #{match.inspect} for :match, should be one of #{VALID_MATCH.map(&:inspect).join(", ")}"
        end
      end

      def filtered_xpath(expr)
        if options.has_key?(:id) || options.has_key?(:class)
          expr = "(#{expr})"
          expr = "#{expr}[#{XPath.attr(:id) == options[:id]}]" if options.has_key?(:id) && !custom_keys.include?(:id)
          if options.has_key?(:class) && !custom_keys.include?(:class)
            class_xpath = Array(options[:class]).map do |klass|
              "contains(concat(' ',normalize-space(@class),' '),' #{klass} ')"
            end.join(" and ")
            expr = "#{expr}[#{class_xpath}]"
          end
        end
        expr
      end

      def filtered_css(expr)
        if options.has_key?(:id) || options.has_key?(:class)
          css_selectors = expr.split(',').map(&:rstrip)
          expr = css_selectors.map do |sel|
           sel += "##{Capybara::Selector::CSS.escape(options[:id])}" if options.has_key?(:id) && !custom_keys.include?(:id)
           sel += Array(options[:class]).map { |k| ".#{Capybara::Selector::CSS.escape(k)}"}.join if options.has_key?(:class) && !custom_keys.include?(:class)
           sel
          end.join(", ")
        end
        expr
      end

      def warn_exact_usage
        if options.has_key?(:exact) && !supports_exact?
          warn "The :exact option only has an effect on queries using the XPath#is method. Using it with the query \"#{expression.to_s}\" has no effect."
        end
      end
    end
  end
end
