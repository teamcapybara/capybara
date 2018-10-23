# frozen_string_literal: true

require 'minitest/spec'

module Capybara
  module Minitest
    module Expectations
      %w[text content title current_path].each do |assertion|
        infect_an_assertion "assert_#{assertion}", "must_have_#{assertion}", :reverse
        infect_an_assertion "refute_#{assertion}", "wont_have_#{assertion}", :reverse
      end

      # rubocop:disable Style/MultilineBlockChain
      (%w[selector xpath css link button field select table checked_field unchecked_field].flat_map do |assertion|
        [%W[assert_#{assertion} must_have_#{assertion}],
         %W[refute_#{assertion} wont_have_#{assertion}]]
      end + [%w[assert_all_of_selectors must_have_all_of_selectors],
             %w[assert_none_of_selectors must_have_none_of_selectors],
             %w[assert_any_of_selectors must_have_any_of_selectors],
             %w[assert_style must_have_style]] +
      %w[selector xpath css].flat_map do |assertion|
        [%W[assert_matches_#{assertion} must_match_#{assertion}],
         %W[refute_matches_#{assertion} wont_match_#{assertion}]]
      end).each do |(meth, new_name)|
        class_eval <<-ASSERTION, __FILE__, __LINE__ + 1
          def #{new_name} *args, &block
            ::Minitest::Expectation.new(self, ::Minitest::Spec.current).#{new_name}(*args, &block)
          end
        ASSERTION

        ::Minitest::Expectation.class_eval <<-ASSERTION, __FILE__, __LINE__ + 1
          def #{new_name} *args, &block
            ctx.#{meth}(target, *args, &block)
          end
        ASSERTION
      end
      # rubocop:enable Style/MultilineBlockChain

      ##
      # Expectation that there is xpath
      #
      # @!method must_have_xpath
      #   see Capybara::Node::Matchers#has_xpath?

      ##
      # Expectation that there is no xpath
      #
      # @!method wont_have_xpath
      #   see Capybara::Node::Matchers#has_no_xpath?

      ##
      # Expectation that there is css
      #
      # @!method must_have_css
      #   see Capybara::Node::Matchers#has_css?

      ##
      # Expectation that there is no css
      #
      # @!method wont_have_css
      #   see Capybara::Node::Matchers#has_no_css?

      ##
      # Expectation that there is link
      #
      # @!method must_have_link
      #   see {Capybara::Node::Matchers#has_link?}

      ##
      # Expectation that there is no link
      #
      # @!method wont_have_link
      # see {Capybara::Node::Matchers#has_no_link?}

      ##
      # Expectation that there is button
      #
      # @!method must_have_button
      #   see {Capybara::Node::Matchers#has_button?}

      ##
      # Expectation that there is no button
      #
      # @!method wont_have_button
      #   see {Capybara::Node::Matchers#has_no_button?}

      ##
      # Expectation that there is field
      #
      # @!method must_have_field
      #   see {Capybara::Node::Matchers#has_field?}

      ##
      # Expectation that there is no field
      #
      # @!method wont_have_field
      #   see {Capybara::Node::Matchers#has_no_field?}

      ##
      # Expectation that there is checked_field
      #
      # @!method must_have_checked_field
      #   see {Capybara::Node::Matchers#has_checked_field?}

      ##
      # Expectation that there is no checked_field
      #
      # @!method wont_have_chceked_field

      ##
      # Expectation that there is unchecked_field
      #
      # @!method must_have_unchecked_field
      #   see {Capybara::Node::Matchers#has_unchecked_field?}

      ##
      # Expectation that there is no unchecked_field
      #
      # @!method wont_have_unchceked_field

      ##
      # Expectation that there is select
      #
      # @!method must_have_select
      #   see {Capybara::Node::Matchers#has_select?}

      ##
      # Expectation that there is no select
      #
      # @!method wont_have_select
      #   see {Capybara::Node::Matchers#has_no_select?}

      ##
      # Expectation that there is table
      #
      # @!method must_have_table
      #   see {Capybara::Node::Matchers#has_table?}

      ##
      # Expectation that there is no table
      #
      # @!method wont_have_table
      #   see {Capybara::Node::Matchers#has_no_table?}

      ##
      # Expectation that page title does match
      #
      # @!method must_have_title
      #   see {Capybara::Node::DocumentMatchers#assert_title}

      ##
      # Expectation that page title does not match
      #
      # @!method wont_have_title
      #   see {Capybara::Node::DocumentMatchers#assert_no_title}

      ##
      # Expectation that current path matches
      #
      # @!method must_have_current_path
      #   see {Capybara::SessionMatchers#assert_current_path}

      ##
      # Expectation that current page does not match
      #
      # @!method wont_have_current_path
      #   see {Capybara::SessionMatchers#assert_no_current_path}

      ##
      # Expectation that element has style
      #
      # @!method must_have_style
      #   see {Capybara::Node::Matchers#assert_style}
    end
  end
end

class Capybara::Session
  include Capybara::Minitest::Expectations unless ENV['MT_NO_EXPECTATIONS']
end

class Capybara::Node::Base
  include Capybara::Minitest::Expectations unless ENV['MT_NO_EXPECTATIONS']
end

class Capybara::Node::Simple
  include Capybara::Minitest::Expectations unless ENV['MT_NO_EXPECTATIONS']
end
