require 'capybara'
require 'capybara/dsl'

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :truncation

Capybara.app = Rack::Builder.new do
  map "/" do
    use Rails::Rack::Static
    run ActionController::Dispatcher.new
  end
end.to_app 

Capybara.asset_root = Rails.root.join('public')
