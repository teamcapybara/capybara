require 'capybara'
require 'capybara/dsl'

Capybara.app = Rack::Builder.new do
  map "/" do
    if Rails.version.to_f >= 3.0
      run Rails.application
    else # Rails 2
      use Rails::Rack::Static
      run ActionController::Dispatcher.new
    end
  end
end.to_app

Capybara.asset_root = Rails.root.join('public')
if Rails.version.to_f >= 3.0
  Capybara.asset_servers = {"http://127.0.0.1:3000" => ['assets']}
end
Capybara.save_and_open_page_path = Rails.root.join('tmp/capybara')
