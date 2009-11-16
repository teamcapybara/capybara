require 'webcat'
require 'webcat/dsl'

World(Webcat)

After do
  Webcat.reset_sessions!
end

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :truncation

Before('@javascript') do
  Webcat.current_driver = Webcat.javascript_driver
end

After('@javascript') do
  Webcat.use_default_driver
end