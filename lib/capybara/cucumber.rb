require 'capybara'
require 'capybara/dsl'

World(Capybara)

Before do
  Capybara.reset_sessions!
  Capybara.use_default_driver
end

Before('@javascript') do
  Capybara.current_driver = Capybara.javascript_driver
end

Before('@selenium') do
  Capybara.current_driver = :selenium
end

Before('@celerity') do
  Capybara.current_driver = :celerity
end

Before('@culerity') do
  Capybara.current_driver = :culerity
end

Before('@rack_test') do
  Capybara.current_driver = :rack_test
end
