require 'capybara'
require 'capybara/dsl'

Capybara.app = Rack::Builder.new do
  map "/" do
    ActionDispatch::Static
    run Rails.application  
  end
end.to_app

Capybara.asset_root = Rails.root.join('public')

