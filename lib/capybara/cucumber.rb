require 'capybara'
require 'capybara/dsl'

World(Capybara)

After do
  Capybara.reset_sessions!
end

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :truncation

Before('@javascript') do
  Capybara.current_driver = Capybara.javascript_driver
end

After('@javascript') do
  Capybara.use_default_driver
end