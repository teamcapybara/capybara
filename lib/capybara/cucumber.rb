require 'capybara'
require 'capybara/dsl'

World(Capybara)

After do
  Capybara.reset_sessions!
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

After do
  Capybara.use_default_driver
end

Before do
  if Capybara.save_failed_scenarios && !$capybara_failed_scenarios_have_been_deleted
    require 'capybara/util/save_and_open_page'
    Capybara.delete_saved_pages
    $capybara_failed_scenarios_have_been_deleted = true
  end
end

After do |scenario|
  if Capybara.save_failed_scenarios && scenario.failed?
    name = scenario.name
    name = "#{scenario.scenario_outline.name}_00_#{name}" if scenario.respond_to? :scenario_outline
    name = name.gsub /\s/, '_'
    Capybara.save_page(body, "#{name}.html")
  end
end
