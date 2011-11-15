require 'capybara'

require 'capybara/dsl'
require 'capybara/rspec/matchers'

World(Capybara::DSL)
World(Capybara::RSpecMatchers)

After do
  Capybara.reset_sessions!
end

Before '@debug' do
  @original_debug = Capybara.debug
  Capybara.debug = true
end

After '@debug' do
  Capybara.debug = @original_debug
end

Before '@javascript' do
  Capybara.current_driver = Capybara.javascript_driver
end

Before do |scenario|
  scenario.source_tag_names.each do |tag|
    driver_name = tag.sub(/^@/, '').to_sym
    if Capybara.drivers.has_key?(driver_name)
      Capybara.current_driver = driver_name
    end
  end
end

After do
  Capybara.use_default_driver
end
