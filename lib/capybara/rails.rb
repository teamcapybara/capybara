require 'capybara'
require 'capybara/dsl'

Capybara.app = Rack::Builder.new do
  map "/" do
    if Rails.version.to_f >= 3.0
      app = Rails.application
      app.config.action_dispatch.show_exceptions = true
      run app
    else # Rails 2
      use Rails::Rack::Static
      run ActionController::Dispatcher.new
    end
  end
end.to_app

Capybara.asset_root = Rails.root.join('public')
Capybara.save_and_open_page_path = Rails.root.join('tmp/capybara')

