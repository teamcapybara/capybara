source :rubygems

gem 'bundler', '~> 1.0'
gem "ruby-debug"
gemspec

@dependencies.delete_if {|d| d.name == "xpath" }
gem 'xpath', :path => 'xpath'
