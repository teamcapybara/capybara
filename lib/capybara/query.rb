module Capybara
  # @deprecated This class and its methods are not supposed to be used by users of Capybara's public API.
  #   It may be removed in future versions of Capybara.
  class Query < Queries::BaseQuery
    attr_accessor :selector, :locator, :options, :expression, :find, :negative

    VALID_KEYS = [:text, :visible, :between, :count, :maximum, :minimum, :exact, :match, :wait]
    VALID_MATCH = [:first, :smart, :prefer_exact, :one]

    def initialize(*args)
      @options = if args.last.is_a?(Hash) then args.pop.dup else {} end

      if args[0].is_a?(Symbol)
        @selector = Selector.all[args[0]]
        @locator = args[1]
      else
        @selector = Selector.all.values.find { |s| s.match?(args[0]) }
        @locator = args[0]
      end
      @selector ||= Selector.all[Capybara.default_selector]

      # for compatibility with Capybara 2.0
      if Capybara.exact_options and @selector == Selector.all[:option]
        @options[:exact] = true
      end

      @expression = @selector.call(@locator)
      assert_valid_keys
    end

    def name; selector.name; end
    def label; selector.label or selector.name; end

    def description
      @description = "#{label} #{locator.inspect}"
      @description << " with text #{options[:text].inspect}" if options[:text]
      @description << selector.description(options)
      @description
    end

    def matches_filters?(node)
      if options[:text]
        regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text].to_s)
        return false if not node.text(visible).match(regexp)
      end
      case visible
        when :visible then return false unless node.visible?
        when :hidden then return false if node.visible?
      end
      selector.custom_filters.each do |name, filter|
        if options.has_key?(name)
          return false unless filter.matches?(node, options[name])
        elsif filter.default?
          return false unless filter.matches?(node, filter.default)
        end
      end
    end

    def visible
      if options.has_key?(:visible)
        case @options[:visible]
          when true then :visible
          when false then :all
          else @options[:visible]
        end
      else
        if Capybara.ignore_hidden_elements
          :visible
        else
          :all
        end
      end
    end

    def exact?
      if options.has_key?(:exact)
        @options[:exact]
      else
        Capybara.exact
      end
    end

    def match
      if options.has_key?(:match)
        @options[:match]
      else
        Capybara.match
      end
    end

    def xpath(exact=nil)
      exact = self.exact? if exact == nil
      if @expression.respond_to?(:to_xpath) and exact
        @expression.to_xpath(:exact)
      else
        @expression.to_s
      end
    end

    def css
      @expression
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

    private

    def valid_keys
      COUNT_KEYS + [:text, :visible, :exact, :match, :wait] + @selector.custom_filters.keys
    end

    def assert_valid_keys
      super
      unless VALID_MATCH.include?(match)
        raise ArgumentError, "invalid option #{match.inspect} for :match, should be one of #{VALID_MATCH.map(&:inspect).join(", ")}"
      end
    end
  end
end
