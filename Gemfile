source 'https://rubygems.org'

gem 'bundler', '~> 1.1'
gemspec

gem 'xpath', git: 'git://github.com/teamcapybara/xpath.git'
gem 'webdrivers', git: 'git://github.com/hron/webdrivers', branch: 'iedriver-sorting-fix' if ENV['CI']

group :doc do
  gem 'redcarpet', platforms: :mri
end
