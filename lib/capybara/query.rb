module Capybara
  class Query
    attr_accessor :selector, :locator, :options, :find, :negative

    VALID_KEYS = [:between, :count, :maximum, :minimum]

    def initialize(*args)
      @options = if args.last.is_a?(Hash) then args.pop.dup else {} end

      unless options.has_key?(:visible)
        @options[:visible] = Capybara.ignore_hidden_elements
      end

      if args[0].is_a?(Symbol)
        @selector = Selector.all[args[0]]
        @locator = args[1]
      else
        @selector = Selector.all.values.find { |s| s.select?(args[0]) }
        @locator = args[0]
      end
      @selector ||= Selector.all[Capybara.default_selector]

      assert_valid_keys!
    end

    def name; selector.name; end
    def label; selector.label or selector.name; end

    def description
      @description = "#{label} #{locator.inspect}"
      @description << " with text #{options[:text].inspect}" if options[:text]
      @description
    end

    def compileable_filters
      selector.filters.values.select(&:compile)
    end

    def other_filters
      selector.filters.values - compileable_filters
    end

    def xpath
      base = selector.default_filter.run_compile(selector.xpath, @locator)
      compileable_filters.inject(base) do |xpath, filter|
        if options.has_key?(filter.name)
          filter.run_compile(xpath, options[filter.name])
        else
          xpath
        end
      end
    end

    def resolve!(parent)
      elements = parent.synchronize do
        parent.base.find(xpath.to_s).map do |node|
          matches_filters? Capybara::Node::Element.new(parent.session, node, parent, self)
        end
      end
      Capybara::Result.new(elements.compact, self)
    end

    def matches_filters?(node)
      node.unsynchronized do
        other_filters.each do |filter|
          return nil if options.has_key?(filter.name) and not filter.match?(node, options[filter.name])
        end
      end
      node
    end

    def matches_count?(count)
      case
      when options[:between]
        options[:between] === count
      when options[:count]
        options[:count].to_i == count
      when options[:maximum]
        options[:maximum].to_i >= count
      when options[:minimum]
        options[:minimum].to_i <= count
      else
        count > 0
      end
    end

  private

    def assert_valid_keys!
      valid_keys = VALID_KEYS + @selector.filters.keys
      invalid_keys = @options.keys - valid_keys
      unless invalid_keys.empty?
        invalid_names = invalid_keys.map(&:inspect).join(", ")
        valid_names = valid_keys.map(&:inspect).join(", ")
        raise ArgumentError, "invalid keys #{invalid_names}, should be one of #{valid_names}"
      end
    end
  end
end
