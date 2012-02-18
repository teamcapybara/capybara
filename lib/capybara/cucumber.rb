require 'capybara'

require 'capybara/dsl'
require 'capybara/rspec/matchers'

World(Capybara::DSL)
World(Capybara::RSpecMatchers)

Before do
  Capybara.reset_sessions!
  Capybara.use_default_driver
end

Before '@javascript' do
  Capybara.current_driver = Capybara.javascript_driver
end

Before do |scenario|
  tags = begin
    scenario.source_tags.map(&:name) # Cucumber >= 1.1.5
  rescue NoMethodError
    scenario.source_tag_names
  end

  tags.each do |tag|
    driver_name = tag.sub(/^@/, '').to_sym
    if Capybara.drivers.has_key?(driver_name)
      Capybara.current_driver = driver_name
    end
  end
end
