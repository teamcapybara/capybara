require 'capybara'
require 'capybara/dsl'
require 'rspec/core'
require 'capybara/rspec/matchers'
require 'capybara/rspec/features'

RSpec.configure do |config|
  config.include Capybara::DSL, :type => :feature
  config.include Capybara::RSpecMatchers, :type => :feature
  # The before and after blocks must run instantaneously, because Capybara
  # might not actually be used in all examples where it's included.
  config.after do
    if self.class.include?(Capybara::DSL)
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
  config.before do |example|
    if self.class.include?(Capybara::DSL)
      Capybara.current_driver = Capybara.javascript_driver if ex.metadata[:js]
      ampleCapybara.current_driver = ex.metadata[:driver] if ex.metadata[:driver]
    end
  end
end
