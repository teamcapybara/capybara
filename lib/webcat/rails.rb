require 'webcat'
require 'webcat/dsl'

Webcat.app = ActionController::Dispatcher.new
Webcat.asset_root = Rails.root.join('public')