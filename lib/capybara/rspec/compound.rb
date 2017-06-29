module Capybara
  module RSpecMatchers
    module Compound
      include ::RSpec::Matchers::Composable

      def and(matcher)
        Capybara::RSpecMatchers::Compound::And.new(self,matcher)
      end

      def and_then(matcher)
        ::RSpec::Matchers::BuiltIn::Compound::And.new(self, matcher)
      end

      def or(matcher)
        Capybara::RSpecMatchers::Compound::Or.new(self, matcher)
      end


      class CapybaraEvaluator
        def initialize(actual, matcher_1, matcher_2)
          @actual        = actual
          @matcher_1     = matcher_1
          @matcher_2     = matcher_2
          @match_results = Hash.new { |h, matcher| h[matcher] = matcher.matches?(@actual) }
        end

        def matcher_matches?(matcher)
          @match_results[matcher]
        end

        def reset
          @match_results.clear
        end
      end

      class And < ::RSpec::Matchers::BuiltIn::Compound::And

      private

        def match(_expected, actual)
          @evaluator = CapybaraEvaluator.new(actual, matcher_1, matcher_2)
          syncer = sync_element(actual)
          begin
            syncer.synchronize do
              @evaluator.reset
              raise ::Capybara::ElementNotFound unless [matcher_1_matches?, matcher_2_matches?].all?
              true
            end
          rescue
            false
          end
        end

        def sync_element(el)
          if el.respond_to? :synchronize
            el
          elsif el.respond_to? :current_scope
            el.current_scope
          else
            Capybara.string(el)
          end
        end
      end

      class Or < ::RSpec::Matchers::BuiltIn::Compound::Or

      private

        def match(_expected, actual)
          @evaluator = CapybaraEvaluator.new(actual, matcher_1, matcher_2)
          syncer = sync_element(actual)
          begin
            syncer.synchronize do
              @evaluator.reset
              raise ::Capybara::ElementNotFound unless [matcher_1_matches?, matcher_2_matches?].any?
              true
            end
          rescue
            false
          end
        end

        def sync_element(el)
          if el.respond_to? :synchronize
            el
          elsif el.respond_to? :current_scope
            el.current_scope
          else
            Capybara.string(el)
          end
        end
      end
    end
  end
end
