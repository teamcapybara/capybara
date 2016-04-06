# frozen_string_literal: true
require 'capybara/selector/filter'

module Capybara
  class Selector

    attr_reader :name, :custom_filters, :format

    class << self
      def all
        @selectors ||= {}
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
      @custom_filters = {}
      @match = nil
      @label = nil
      @failure_message = nil
      @description = nil
      @format = nil
      @expression = nil
      instance_eval(&block)
    end

    def xpath(&block)
      @format, @expression = :xpath, block if block
      @format == :xpath ? @expression : nil
    end

    def css(&block)
      @format, @expression = :css, block if block
      @format == :css ? @expression : nil
    end

    def dynamic(&block)
      @format, @expression = :dynamic, block if block
      @format == :dynamic ? @expression : nil
    end

    def match(&block)
      @match = block if block
      @match
    end

    def label(label=nil)
      @label = label if label
      @label
    end

    def description(options={})
      (@description && @description.call(options)).to_s
    end

    def call(locator)
      if format
        @expression.call(locator)
      else
        warn "No selector format"
      end
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, options={}, &block)
      @custom_filters[name] = Filter.new(name, block, options)
    end

    def describe &block
      @description = block
    end

    private

    def locate_field(xpath, locator)
      locate_field = xpath[XPath.attr(:id).equals(locator) |
                           XPath.attr(:name).equals(locator) |
                           XPath.attr(:placeholder).equals(locator) |
                           XPath.attr(:id).equals(XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for))]
      locate_field += XPath.descendant(:label)[XPath.string.n.is(locator)].descendant(xpath)
      locate_field
    end
  end
end
