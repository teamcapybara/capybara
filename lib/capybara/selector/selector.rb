# frozen_string_literal: true
require 'capybara/selector/filter_set'

module Capybara
  class Selector

    attr_reader :name, :format, :expression_filters

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
      @filter_set = FilterSet.add(name){}
      @match = nil
      @label = nil
      @failure_message = nil
      @description = nil
      @format = nil
      @expression = nil
      instance_eval(&block)
    end

    def custom_filters
      @filter_set.filters
    end

    def xpath(*expression_filters, &block)
      @format, @expression_filters, @expression = :xpath, expression_filters.flatten, block if block
      format == :xpath ? @expression : nil
    end

    def css(*expression_filters, &block)
      @format, @expression_filters, @expression = :css, expression_filters.flatten, block if block
      format == :css ? @expression : nil
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
      @filter_set.description(options)
    end

    def call(locator, options={})
      if format
        # @expression.call(locator, options.select {|k,v| @expression_filters.include?(k)})
        @expression.call(locator, options)
      else
        warn "Selector has no format"
      end
    end

    def match?(locator)
      @match and @match.call(locator)
    end

    def filter(name, options={}, &block)
      custom_filters[name] = Filter.new(name, block, options)
    end

    def filter_set(name, filters_to_use = nil)
      f_set = FilterSet.all[name]
      f_set.filters.each do | name, filter |
        custom_filters[name] = filter if filters_to_use.nil? || filters_to_use.include?(name)
      end
      f_set.descriptions.each { |desc| @filter_set.describe &desc }
    end

    def describe &block
      @filter_set.describe &block
    end

    private

    def locate_field(xpath, locator, options={})
      locate_field = xpath
      if locator
        locator = locator.to_s
        attr_matchers =  XPath.attr(:id).equals(locator) |
                         XPath.attr(:name).equals(locator) |
                         XPath.attr(:placeholder).equals(locator) |
                         XPath.attr(:id).equals(XPath.anywhere(:label)[XPath.string.n.is(locator)].attr(:for))
        attr_matchers |= XPath.attr(:'aria-label').is(locator) if Capybara.enable_aria_label

        locate_field = locate_field[attr_matchers]
        locate_field += XPath.descendant(:label)[XPath.string.n.is(locator)].descendant(xpath)
      end
      [:id, :name, :placeholder].each { |ef| locate_field = locate_field[XPath.attr(ef).equals(options[ef])] if options[ef] }
      locate_field
    end
  end
end
