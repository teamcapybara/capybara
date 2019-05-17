# frozen_string_literal: true

require 'minitest'
require 'capybara/dsl'

module Capybara
  module Minitest
    module Assertions
      ## Assert text exists
      #
      # @!method assert_text
      #  see {Capybara::Node::Matchers#assert_text}

      ## Assert text does not exist
      #
      # @!method assert_no_text
      #  see {Capybara::Node::Matchers#assert_no_text}

      ##
      # Assertion that page title does match
      #
      # @!method assert_title
      #   see {Capybara::Node::DocumentMatchers#assert_title}

      ##
      # Assertion that page title does not match
      #
      # @!method refute_title
      # @!method assert_no_title
      #   see {Capybara::Node::DocumentMatchers#assert_no_title}

      ##
      # Assertion that current path matches
      #
      # @!method assert_current_path
      #   see {Capybara::SessionMatchers#assert_current_path}

      ##
      # Assertion that current page does not match
      #
      # @!method refute_current_path
      # @!method assert_no_current_path
      #   see {Capybara::SessionMatchers#assert_no_current_path}

      %w[text no_text title no_title current_path no_current_path].each do |assertion_name|
        class_eval <<-ASSERTION, __FILE__, __LINE__ + 1
          def assert_#{assertion_name} *args
            self.assertions +=1
            subject, args = determine_subject(args)
            subject.assert_#{assertion_name}(*args)
          rescue Capybara::ExpectationNotMet => e
            raise ::Minitest::Assertion, e.message
          end
        ASSERTION
      end

      alias_method :refute_title, :assert_no_title
      alias_method :refute_text, :assert_no_text
      alias_method :refute_content, :refute_text
      alias_method :refute_current_path, :assert_no_current_path
      alias_method :assert_content, :assert_text
      alias_method :assert_no_content, :refute_text

      ## Assert selector exists on page
      #
      # @!method assert_selector
      #   see {Capybara::Node::Matchers#assert_selector}

      ## Assert selector does not exist on page
      #
      # @!method assert_no_selector
      #   see {Capybara::Node::Matchers#assert_no_selector}

      ## Assert element matches selector
      #
      # @!method assert_matches_selector
      #   see {Capybara::Node::Matchers#assert_matches_selector}

      ## Assert element does not match selector
      #
      # @!method assert_xpath
      #   see {Capybara::Node::Matchers#assert_not_matches_selector}

      ## Assert element has the provided CSS styles
      #
      # @!method assert_matches_style
      #   see {Capybara::Node::Matchers#assert_matches_style}

      %w[selector no_selector matches_style
         all_of_selectors none_of_selectors any_of_selectors
         matches_selector not_matches_selector].each do |assertion_name|
        class_eval <<-ASSERTION, __FILE__, __LINE__ + 1
          def assert_#{assertion_name} *args, &optional_filter_block
            self.assertions +=1
            subject, args = determine_subject(args)
            subject.assert_#{assertion_name}(*args, &optional_filter_block)
          rescue Capybara::ExpectationNotMet => e
            raise ::Minitest::Assertion, e.message
          end
        ASSERTION
      end

      alias_method :refute_selector, :assert_no_selector
      alias_method :refute_matches_selector, :assert_not_matches_selector

      %w[xpath css link button field select table].each do |selector_type|
        define_method "assert_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_selector(subject, selector_type.to_sym, locator, options, &optional_filter_block)
        end

        define_method "assert_no_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_no_selector(subject, selector_type.to_sym, locator, options, &optional_filter_block)
        end
        alias_method "refute_#{selector_type}", "assert_no_#{selector_type}"
      end

      %w[checked unchecked].each do |field_type|
        define_method "assert_#{field_type}_field" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_selector(subject, :field, locator, options.merge(field_type.to_sym => true), &optional_filter_block)
        end

        define_method "assert_no_#{field_type}_field" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          locator, options = extract_locator(args)
          assert_no_selector(subject, :field, locator, options.merge(field_type.to_sym => true), &optional_filter_block)
        end
        alias_method "refute_#{field_type}_field", "assert_no_#{field_type}_field"
      end

      %w[xpath css].each do |selector_type|
        define_method "assert_matches_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          assert_matches_selector(subject, selector_type.to_sym, *args, &optional_filter_block)
        end

        define_method "assert_not_matches_#{selector_type}" do |*args, &optional_filter_block|
          subject, args = determine_subject(args)
          assert_not_matches_selector(subject, selector_type.to_sym, *args, &optional_filter_block)
        end
        alias_method "refute_matches_#{selector_type}", "assert_not_matches_#{selector_type}"
      end

    ##
    # Assertion that there is xpath
    #
    # @!method assert_xpath
    #   see {Capybara::Node::Matchers#has_xpath?}

    ##
    # Assertion that there is no xpath
    #
    # @!method refute_xpath
    # @!method assert_no_xpath
    #   see {Capybara::Node::Matchers#has_no_xpath?}

    ##
    # Assertion that there is css
    #
    # @!method assert_css
    #   see {Capybara::Node::Matchers#has_css?}

    ##
    # Assertion that there is no css
    #
    # @!method refute_css
    # @!method assert_no_css
    #   see {Capybara::Node::Matchers#has_no_css?}

    ##
    # Assertion that there is link
    #
    # @!method assert_link
    #   see {Capybara::Node::Matchers#has_link?}

    ##
    # Assertion that there is no link
    #
    # @!method assert_no_link
    # @!method refute_link
    # see {Capybara::Node::Matchers#has_no_link?}

    ##
    # Assertion that there is button
    #
    # @!method assert_button
    #   see {Capybara::Node::Matchers#has_button?}

    ##
    # Assertion that there is no button
    #
    # @!method refute_button
    # @!method assert_no_button
    #   see {Capybara::Node::Matchers#has_no_button?}

    ##
    # Assertion that there is field
    #
    # @!method assert_field
    #   see {Capybara::Node::Matchers#has_field?}

    ##
    # Assertion that there is no field
    #
    # @!method refute_field
    # @!method assert_no_field
    #   see {Capybara::Node::Matchers#has_no_field?}

    ##
    # Assertion that there is checked_field
    #
    # @!method assert_checked_field
    #   see {Capybara::Node::Matchers#has_checked_field?}

    ##
    # Assertion that there is no checked_field
    #
    # @!method assert_no_checked_field
    # @!method refute_checked_field

    ##
    # Assertion that there is unchecked_field
    #
    # @!method assert_unchecked_field
    #   see {Capybara::Node::Matchers#has_unchecked_field?}

    ##
    # Assertion that there is no unchecked_field
    #
    # @!method assert_no_unchecked_field
    # @!method refute_unchecked_field

    ##
    # Assertion that there is select
    #
    # @!method assert_select
    #   see {Capybara::Node::Matchers#has_select?}

    ##
    # Assertion that there is no select
    #
    # @!method refute_select
    # @!method assert_no_select
    #   see {Capybara::Node::Matchers#has_no_select?}

    ##
    # Assertion that there is table
    #
    # @!method assert_table
    #   see {Capybara::Node::Matchers#has_table?}

    ##
    # Assertion that there is no table
    #
    # @!method refute_table
    # @!method assert_no_table
    #   see {Capybara::Node::Matchers#has_no_table?}

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
