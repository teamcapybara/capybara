# frozen_string_literal: true

require 'minitest'
require 'capybara/dsl'

module Capybara
  module Minitest
    module Assertions
      ##
      # Define a Minitest assertion that forwards its arguments to the provided
      # subject:
      #
      #     asserts :text
      #
      #     test "Has an element with text" do
      #       visit "/"
      #
      #       assert_text page.find(id: "the-element"), "The element's text"
      #     end
      #
      # @param [Symbol] assertion_names Name of the underlying assertion
      def self.asserts(*assertion_names)
        assertion_names.each do |assertion_name|
          method_name = "assert_#{assertion_name}"

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, **kwargs, &optional_filter_block)
              self.assertions +=1
              subject, args = determine_subject(args)
              subject.#{method_name}(*args, **kwargs, &optional_filter_block)
            rescue Capybara::ExpectationNotMet => e
              raise ::Minitest::Assertion, e.message
            end
          RUBY
          ruby2_keywords method_name if respond_to?(:ruby2_keywords)
        end
      end

      ##
      # Define a Minitest refutation that forwards its arguments to the provided
      # subject:
      #
      #     asserts_no :text
      #
      #     test "Has an element without text" do
      #       visit "/"
      #
      #       assert_no_text page.find(id: "the-element"), "Some other text"
      #     end
      #
      # Also defines an alias for the assertion in the refute style:
      #
      #     test "Has an element without text" do
      #       visit "/"
      #
      #       refute_text page.find(id: "the-element"), "Some other text"
      #     end
      #
      # @param [Symbol] assertion_names Name of the underlying assertion
      def self.asserts_no(*assertion_names)
        assertion_names.each do |assertion_name|
          method_name = "assert_no_#{assertion_name}"

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, **kwargs, &optional_filter_block)
              self.assertions +=1
              subject, args = determine_subject(args)
              subject.#{method_name}(*args, **kwargs, &optional_filter_block)
            rescue Capybara::ExpectationNotMet => e
              raise ::Minitest::Assertion, e.message
            end
          RUBY
          ruby2_keywords method_name if respond_to?(:ruby2_keywords)
          alias_method "refute_#{assertion_name}", method_name
        end
      end

      ##
      # Define a Minitest selector assertion that forwards its arguments to the
      # provided subject:
      #
      #     asserts_selector :element
      #
      #     test "Has an element with text" do
      #       visit "/"
      #
      #       assert_element page.find(id: "parent"), "div", text: "The child's text"
      #     end
      #
      # @param [Symbol] selector_types Name of the underlying selector
      def self.asserts_selector(*selector_types)
        selector_types.each do |selector_type|
          method_name = "assert_#{selector_type}"

          define_method method_name do |*args, &optional_filter_block|
            subject, args = determine_subject(args)
            locator, options = extract_locator(args)
            assert_selector(subject, selector_type.to_sym, locator, **options, &optional_filter_block)
          end
          ruby2_keywords method_name if respond_to?(:ruby2_keywords)
        end
      end

      ##
      # Define a Minitest selector refutation that forwards its arguments to the
      # provided subject:
      #
      #     asserts_no :text
      #
      #     test "Has an element without text" do
      #       visit "/"
      #
      #       assert_no_element page.find(id: "parent"), "div", text: "The child's text"
      #     end
      #
      # Also defines an alias for the assertion in the refute style:
      #
      #     test "Has an element without text" do
      #       visit "/"
      #
      #       refute_element page.find(id: "parent"), "div", text: "The child's text"
      #     end
      #
      def self.asserts_no_selector(*selector_types)
        selector_types.each do |selector_type|
          method_name = "assert_no_#{selector_type}"

          define_method method_name do |*args, &optional_filter_block|
            subject, args = determine_subject(args)
            locator, options = extract_locator(args)
            assert_no_selector(subject, selector_type.to_sym, locator, **options, &optional_filter_block)
          end
          ruby2_keywords method_name if respond_to?(:ruby2_keywords)
          alias_method "refute_#{selector_type}", method_name
        end
      end

      ##
      # Assert text exists
      #
      # @!method assert_content
      # @!method assert_text
      #   See {Capybara::Node::Matchers#assert_text}
      asserts :text
      alias_method :assert_content, :assert_text

      ##
      # Assert text does not exist
      #
      # @!method refute_content
      # @!method assert_no_content
      # @!method refute_text
      # @!method assert_no_text
      #   See {Capybara::Node::Matchers#assert_no_text}
      asserts_no :text
      alias_method :refute_content, :refute_text
      alias_method :assert_no_content, :refute_text

      ##
      # Assertion that page title does match
      #
      # @!method assert_title
      #   See {Capybara::Node::DocumentMatchers#assert_title}
      asserts :title

      ##
      # Assertion that page title does not match
      #
      # @!method refute_title
      # @!method assert_no_title
      #   See {Capybara::Node::DocumentMatchers#assert_no_title}
      asserts_no :title

      ##
      # Assertion that current path matches
      #
      # @!method assert_current_path
      #   See {Capybara::SessionMatchers#assert_current_path}
      asserts :current_path

      ##
      # Assertion that current page does not match
      #
      # @!method refute_current_path
      # @!method assert_no_current_path
      #   See {Capybara::SessionMatchers#assert_no_current_path}
      asserts_no :current_path

      ##
      # Assert selector exists on page
      #
      # @!method assert_selector
      #   See {Capybara::Node::Matchers#assert_selector}
      asserts_selector :selector

      ##
      # Assert selector does not exist on page
      #
      # @!method refute_selector
      # @!method assert_no_selector
      #   See {Capybara::Node::Matchers#assert_no_selector}
      asserts_no_selector :selector

      ##
      # Assert element matches selector
      #
      # @!method assert_matches_selector
      #   See {Capybara::Node::Matchers#assert_matches_selector}
      asserts_selector :matches_selector

      ##
      # Assert element does not match selector
      #
      # @!method refute_matches_selector
      # @!method assert_not_matches_selector
      #   See {Capybara::Node::Matchers#assert_not_matches_selector}
      asserts_selector :not_matches_selector
      alias_method :refute_matches_selector, :assert_not_matches_selector

      ##
      # Assert all of the provided selectors exist on page
      #
      # @!method assert_all_of_selectors
      #   See {Capybara::Node::Matchers#assert_all_of_selectors}
      asserts_selector :all_of_selectors

      ##
      # Assert none of the provided selectors exist on page
      #
      # @!method assert_none_of_selectors
      #   See {Capybara::Node::Matchers#assert_none_of_selectors}
      asserts_selector :none_of_selectors

      ##
      # Assert any of the provided selectors exist on page
      #
      # @!method assert_any_of_selectors
      #   See {Capybara::Node::Matchers#assert_any_of_selectors}
      asserts_selector :any_of_selectors

      ##
      # Assert element has the provided CSS styles
      #
      # @!method assert_matches_style
      #   See {Capybara::Node::Matchers#assert_matches_style}
      asserts_selector :matches_style

      ##
      # Assert element has a matching sibling
      #
      # @!method assert_sibling
      #   See {Capybara::Node::Matchers#assert_sibling}
      asserts_selector :sibling

      ##
      # Assert element does not have a matching sibling
      #
      # @!method refute_sibling
      # @!method assert_no_sibling
      #   See {Capybara::Node::Matchers#assert_no_sibling}
      asserts_no_selector :sibling

      ##
      # Assert element has a matching ancestor
      #
      # @!method assert_ancestor
      #   See {Capybara::Node::Matchers#assert_ancestor}
      asserts_selector :ancestor

      ##
      # Assert element does not have a matching ancestor
      #
      # @!method refute_ancestor
      # @!method assert_no_ancestor
      #   See {Capybara::Node::Matchers#assert_no_ancestor}
      asserts_no_selector :ancestor

      ##
      # Assert that provided xpath exists
      #
      # @!method assert_xpath
      #   See {Capybara::Node::Matchers#has_xpath?}
      asserts_selector :xpath

      ##
      # Assert that provide xpath does not exist
      #
      # @!method refute_xpath
      # @!method assert_no_xpath
      #   See {Capybara::Node::Matchers#has_no_xpath?}
      asserts_no_selector :xpath

      ##
      # Assert that provided css exists
      #
      # @!method assert_css
      #   See {Capybara::Node::Matchers#has_css?}
      asserts_selector :css

      ##
      # Assert that provided css does not exist
      #
      # @!method refute_css
      # @!method assert_no_css
      #   See {Capybara::Node::Matchers#has_no_css?}
      asserts_no_selector :css

      ##
      # Assert that provided link exists
      #
      # @!method assert_link
      #   See {Capybara::Node::Matchers#has_link?}
      asserts_selector :link

      ##
      # Assert that provided link does not exist
      #
      # @!method assert_no_link
      # @!method refute_link
      #   See {Capybara::Node::Matchers#has_no_link?}
      asserts_no_selector :link

      ##
      # Assert that provided button exists
      #
      # @!method assert_button
      #   See {Capybara::Node::Matchers#has_button?}
      asserts_selector :button

      ##
      # Assert that provided button does not exist
      #
      # @!method refute_button
      # @!method assert_no_button
      #   See {Capybara::Node::Matchers#has_no_button?}
      asserts_no_selector :button

      ##
      # Assert that provided field exists
      #
      # @!method assert_field
      #   See {Capybara::Node::Matchers#has_field?}
      asserts_selector :field

      ##
      # Assert that provided field does not exist
      #
      # @!method refute_field
      # @!method assert_no_field
      #   See {Capybara::Node::Matchers#has_no_field?}
      asserts_no_selector :field

      ##
      # Assert that provided checked field exists
      #
      # @!method assert_checked_field
      #   See {Capybara::Node::Matchers#has_checked_field?}

      ##
      # Assert that provided checked_field does not exist
      #
      # @!method assert_no_checked_field
      # @!method refute_checked_field
      #   See {Capybara::Node::Matchers#has_no_checked_field?}

      ##
      # Assert that provided unchecked field exists
      #
      # @!method assert_unchecked_field
      #   See {Capybara::Node::Matchers#has_unchecked_field?}

      ##
      # Assert that provided unchecked field does not exist
      #
      # @!method assert_no_unchecked_field
      # @!method refute_unchecked_field
      #   See {Capybara::Node::Matchers#has_no_unchecked_field?}

      ##
      # Assert that provided select exists
      #
      # @!method assert_select
      #   See {Capybara::Node::Matchers#has_select?}
      asserts_selector :select

      ##
      # Assert that provided select does not exist
      #
      # @!method refute_select
      # @!method assert_no_select
      #   See {Capybara::Node::Matchers#has_no_select?}
      asserts_no_selector :select

      ##
      # Assert that provided table exists
      #
      # @!method assert_table
      #   See {Capybara::Node::Matchers#has_table?}
      asserts_selector :table

      ##
      # Assert that provided table does not exist
      #
      # @!method refute_table
      # @!method assert_no_table
      #   See {Capybara::Node::Matchers#has_no_table?}
      asserts_no_selector :table

      %w[checked unchecked].each do |field_type|
        define_method "assert_#{field_type}_field" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_selector(subject, :field, locator, **options.merge(field_type.to_sym => true), &optional_filter_block)
        end
        ruby2_keywords "assert_#{field_type}_field" if respond_to?(:ruby2_keywords)

        define_method "assert_no_#{field_type}_field" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_no_selector(
            subject,
            :field,
            locator,
            **options.merge(field_type.to_sym => true),
            &optional_filter_block
          )
        end
        ruby2_keywords "assert_no_#{field_type}_field" if respond_to?(:ruby2_keywords)
        alias_method "refute_#{field_type}_field", "assert_no_#{field_type}_field"
      end

      ##
      # Assert that element matches xpath
      #
      # @!method assert_matches_xpath
      #   See {Capybara::Node::Matchers#matches_xpath?}

      ##
      # Assert that element does not match xpath
      #
      # @!method refute_matches_xpath
      # @!method assert_not_matches_xpath
      #   See {Capybara::Node::Matchers#not_matches_xpath?}

      ##
      # Assert that element matches css
      #
      # @!method assert_matches_css
      #   See {Capybara::Node::Matchers#matches_css?}

      ##
      # Assert that element matches css
      #
      # @!method refute_matches_css
      # @!method assert_not_matches_css
      #   See {Capybara::Node::Matchers#not_matches_css?}

      %w[xpath css].each do |selector_type|
        define_method "assert_matches_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          assert_matches_selector(subject, selector_type.to_sym, *args, &optional_filter_block)
        end
        ruby2_keywords "assert_matches_#{selector_type}" if respond_to?(:ruby2_keywords)

        define_method "assert_not_matches_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          assert_not_matches_selector(subject, selector_type.to_sym, *args, &optional_filter_block)
        end
        ruby2_keywords "assert_not_matches_#{selector_type}" if respond_to?(:ruby2_keywords)
        alias_method "refute_matches_#{selector_type}", "assert_not_matches_#{selector_type}"
      end

    private

      def determine_subject(args)
        case args.first
        when Capybara::Session, Capybara::Node::Base, Capybara::Node::Simple
          [args.shift, args]
        when ->(arg) { arg.respond_to?(:to_capybara_node) }
          [args.shift.to_capybara_node, args]
        else
          [page, args]
        end
      end

      def extract_locator(args)
        locator, options = *args, {}
        locator, options = nil, locator if locator.is_a? Hash
        [locator, options]
      end
    end
  end
end
