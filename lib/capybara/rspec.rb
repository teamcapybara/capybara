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
