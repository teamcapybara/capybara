require 'webcat'
require 'webcat/dsl'

if defined?(Rails)
  Webcat.app = ActionController::Dispatcher.new
end

World(Webcat)

