require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/capybara'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'capybara' do
  self.developer 'Jonas Nicklas', 'jonas.nicklas@gmail.com'
  self.rubyforge_name = self.name # TODO this is default value

  self.extra_deps = [
    ['nokogiri', '>= 1.3.3'],
    ['culerity', '>= 0.2.3'],
    ['selenium-webdriver', '>= 0.0.3'],
    ['rack', '>= 1.0.0'],
    ['database_cleaner', '>= 0.2.3']
  ]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
