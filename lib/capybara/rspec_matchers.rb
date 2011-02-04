module Capybara
  module RSpecMatchers
    extend ::RSpec::Matchers::DSL

    %w[css xpath selector].each do |type|
      matcher "have_#{type}" do |*args|
        match_for_should do |actual|
          wrap(actual).send("has_#{type}?", *args)
        end

        match_for_should_not do |actual|
          wrap(actual).send("has_no_#{type}?", *args)
        end

        failure_message_for_should do |actual|
          "expected #{normalized[:selector].name} #{normalized[:locator].inspect} to return something from:\n#{actual.inspect}"
        end

        failure_message_for_should_not do |actual|
          "expected #{normalized[:selector].name} #{normalized[:locator].inspect} not to return anything from:\n#{actual.inspect}"
        end

        define_method :wrap do |actual|
          if actual.respond_to?("has_#{type}?")
            actual
          else
            Capybara.string(actual.to_s)
          end
        end

        define_method :normalized do
          @normalized ||= if type == "selector"
            Capybara::Selector.normalize(*args)
          else
            Capybara::Selector.normalize(type.to_sym, *args)
          end
        end
      end
    end
  end
end
