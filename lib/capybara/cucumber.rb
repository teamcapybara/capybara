# frozen_string_literal: true
require 'capybara/dsl'
require 'capybara/rspec/matchers'
require 'capybara/rspec/matcher_proxies'

World(Capybara::DSL)
World(Capybara::RSpecMatchers)

# Reset sessions after scenario protects you from hard to debug issues
# because of dependencies between scenarios.
# We advice you not to use @no_reset_sessions where you can write a feature without it
After('~@no_reset_sessions') do
  Capybara.reset_sessions!
end

Before do
  Capybara.use_default_driver
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
