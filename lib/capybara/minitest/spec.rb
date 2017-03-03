require 'minitest/spec'

module Capybara
  module Minitest
    module Expectations
      %w(text content title current_path).each do |assertion|
        infect_an_assertion "assert_#{assertion}", "must_have_#{assertion}", :reverse
        infect_an_assertion "refute_#{assertion}", "wont_have_#{assertion}", :reverse
      end

      # Unfortunately infect_an_assertion doesn't pass through the optional filter block so we can't use it for these
      %w(selector xpath css link button field select table checked_field unchecked_field).each do |assertion|
        self.class_eval <<-EOM
          def must_have_#{assertion} *args, &optional_filter_block
            ::Minitest::Expectation.new(self, ::Minitest::Spec.current).must_have_#{assertion}(*args, &optional_filter_block)
          end

          def wont_have_#{assertion} *args, &optional_filter_block
            ::Minitest::Expectation.new(self, ::Minitest::Spec.current).wont_have_#{assertion}(*args, &optional_filter_block)
          end
        EOM

        ::Minitest::Expectation.class_eval <<-EOM, __FILE__, __LINE__ + 1
          def must_have_#{assertion} *args, &optional_filter_block
            ctx.assert_#{assertion}(target, *args, &optional_filter_block)
          end

          def wont_have_#{assertion} *args, &optional_filter_block
            ctx.refute_#{assertion}(target, *args, &optional_filter_block)
          end
        EOM
      end

      %w(selector xpath css).each do |assertion|
        self.class_eval <<-EOM
          def must_match_#{assertion} *args, &optional_filter_block
            ::Minitest::Expectation.new(self, ::Minitest::Spec.current).must_match_#{assertion}(*args, &optional_filter_block)
          end

          def wont_match_#{assertion} *args, &optional_filter_block
            ::Minitest::Expectation.new(self, ::Minitest::Spec.current).wont_match_#{assertion}(*args, &optional_filter_block)
          end
        EOM

        ::Minitest::Expectation.class_eval <<-EOM, __FILE__, __LINE__ + 1
          def must_match_#{assertion} *args, &optional_filter_block
            ctx.assert_matches_#{assertion}(target, *args, &optional_filter_block)
          end

          def wont_match_#{assertion} *args, &optional_filter_block
            ctx.refute_matches_#{assertion}(target, *args, &optional_filter_block)
          end
        EOM
      end
    end
  end
end

class Capybara::Session
  include Capybara::Minitest::Expectations unless ENV["MT_NO_EXPECTATIONS"]
end

class Capybara::Node::Base
  include Capybara::Minitest::Expectations unless ENV["MT_NO_EXPECTATIONS"]
end

class Capybara::Node::Simple
  include Capybara::Minitest::Expectations unless ENV["MT_NO_EXPECTATIONS"]
end
