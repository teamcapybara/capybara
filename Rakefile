require 'rubygems'

gem 'hoe', '>= 2.1.0'
require 'hoe'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Hoe.spec 'capybara' do
  developer 'Jonas Nicklas', 'jonas.nicklas@gmail.com'

  self.readme_file      = 'README.rdoc'
  self.extra_rdoc_files = Dir['*.rdoc']

  self.extra_deps = [
    ['nokogiri', '>= 1.3.3'],
    ['mime-types', '>= 1.16'],
    ['culerity', '>= 0.2.4'],
    ['selenium-webdriver', '>= 0.0.3'],
    ['rack', '>= 1.0.0'],
    ['rack-test', '>= 0.5.2'],
  ]

  self.extra_dev_deps = [
    ['sinatra', '>= 0.9.4'],
    ['rspec', '>= 1.2.9']
  ]
end
