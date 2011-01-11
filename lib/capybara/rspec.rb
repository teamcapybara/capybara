require 'capybara'
require 'capybara/dsl'

RSpec.configure do |config|
  config.include Capybara, :type => :acceptance
  config.after do
    if example.metadata[:type] == :acceptance
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
  config.before do
    if example.metadata[:type] == :acceptance
      Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
      Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
    end
  end
end

module Capybara
  module RSpec
    module StringMatchers
      extend ::RSpec::Matchers::DSL

      matcher :have_selector do |*args|
        match_for_should do |string|
          Capybara::string(string).has_selector?(*args)
        end

        match_for_should_not do |string|
          Capybara::string(string).has_no_selector?(*args)
        end

        failure_message_for_should do |string|
          "expected selector #{formatted(args)} to return something from:\n#{string}"
        end

        failure_message_for_should_not do |string|
          "expected selector #{formatted(args)} not to return anything from:\n#{string}"
        end

        def formatted(args)
          args.length == 1 ? args.first.inspect : args.inspect
        end
      end

    end
  end
end
