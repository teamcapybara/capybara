module Capybara
  class Query
    attr_accessor :node, :selector, :locator, :options, :xpath, :find, :negative

    def initialize(node, *args)
      @node = node
      @options = if args.last.is_a?(Hash) then args.pop.dup else {} end
      unless options.has_key?(:visible)
        @options[:visible] = Capybara.ignore_hidden_elements
      end

      if args[1]
        @selector = Selector.all[args[0]]
        @locator = args[1]
      else
        @selector = Selector.all.values.find { |s| s.match?(args[0]) }
        @locator = args[0]
      end
      @selector ||= Selector.all[Capybara.default_selector]

      @xpath = @selector.call(@locator).to_s
    end

    def failure_message
      if find
        "Unable to find #{description}"
      else
        "expected #{description} to return something"
      end
    end

    def negative_failure_message
      "expected #{description} not to return anything"
    end

    def name; selector.name; end
    def label; selector.label or selector.name; end

    def description
      @description = "#{label} #{locator.inspect}"
      @description << " with text #{options[:text].inspect}" if options[:text]
      @description
    end

    def matches_filters?(node)
      if options[:text]
        regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text])
        return false if not node.text.match(regexp)
      end
      return false if options[:visible] and not node.visible?
      selector.custom_filters.each do |name, block|
        return false if options.has_key?(name) and not block.call(node, options[name])
      end
      true
    end

    def verify!(results)
      if find and results.length != 1
        raise Capybara::ElementNotFound, failure_message
      end
    end

    def error(results)
      if negative
        negative_failure_message
      else
        failure_message
      end
    end

    def matches_count?(nodes)
      case
      when nodes.empty?
        false
      when options[:between]
        options[:between] === nodes.size
      when options[:count]
        options[:count].to_i == nodes.size
      when options[:maximum]
        options[:maximum].to_i >= nodes.size
      when options[:minimum]
        options[:minimum].to_i <= nodes.size
      else
        nodes.size > 0
      end
    end
  end
end
