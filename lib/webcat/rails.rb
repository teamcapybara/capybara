require 'webcat'
require 'webcat/dsl'

Webcat.app = Rack::Builder.new do
  map "/" do
    use Rails::Rack::Static
    run ActionController::Dispatcher.new
  end
end.to_app 

Webcat.asset_root = Rails.root.join('public')
