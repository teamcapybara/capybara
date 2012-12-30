module Capybara
  class Filter
    attr_reader :name

    class << self
      def all
        @all ||= {}
      end

      def add(name, &block)
        all[name.to_sym] = new(name.to_sym, &block)
      end

      def remove(name)
        all.delete(name.to_sym)
      end
    end

    def initialize(name, &block)
      @name = name
      instance_eval(&block) if block
    end

    def match(&block)
      @match = block if block
      @match
    end

    def compile(&block)
      @compile = block if block
      @compile
    end

    def run_compile(xpath, value)
      @compile and XPath.instance_exec(xpath, value, &@compile)
    end

    def match?(node, value)
      @match and @match.call(node, value)
    end
  end
end

Capybara::Filter.add :text do
  match do |node, value|
    regexp = value.is_a?(Regexp) ? value : Regexp.escape(value)
    node.text.match(regexp)
  end
end

Capybara::Filter.add :visible do
  match do |node, value|
    if value then node.visible? else true end
  end
end
