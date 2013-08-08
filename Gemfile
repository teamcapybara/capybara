source 'https://rubygems.org'

gem 'bundler', '~> 1.0'
gemspec

@dependencies.delete_if {|d| d.name == "xpath" }
gem 'xpath', :git => 'git://github.com/jnicklas/xpath.git', :tag => '1.0.0'
