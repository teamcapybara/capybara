module Capybara
  module Selenium
    autoload :Node,  'capybara/selenium/node'
    autoload :Driver,'capybara/selenium/driver'
  end
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end
