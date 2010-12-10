require 'capybara'
require 'capybara/dsl'

Rspec.configure do |config|
  config.include Capybara
  config.after do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
  config.before do
    Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
    Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
  end
end
