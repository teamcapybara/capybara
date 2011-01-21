source :rubygems

gem 'bundler', '~> 1.0'
gemspec

unless ENV['RACK_ENV']
  @dependencies.delete_if {|d| d.name == "xpath" }
  gem 'xpath', :path => 'xpath'
end
