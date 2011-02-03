require 'capybara'
require 'capybara/dsl'
require 'rspec/core'

RSpec.configure do |config|
  config.include Capybara, :type => :acceptance
  config.include Capybara, :type => :request
  config.after do
    if self.class.include?(Capybara)
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
  config.before do
    if self.class.include?(Capybara)
      Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
      Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
    end
  end
end
