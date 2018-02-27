# frozen_string_literal: true

require 'rubygems'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'yard'

desc "Run all examples with Firefox non-marionette"

RSpec::Core::RakeTask.new(:spec_marionette) do |t|
  t.rspec_opts = %w[--color]
  t.pattern = './spec{,/*/**}/*{_spec.rb,_spec_marionette.rb}'
end

RSpec::Core::RakeTask.new(:spec_chrome) do |t|
  t.rspec_opts = %w[--color]
  t.pattern = './spec/*{_spec_chrome.rb}'
end

RSpec::Core::RakeTask.new(:spec_rack) do |t|
  t.rspec_opts = %w[--color]
  t.pattern = './spec{,/*/**}/*{_spec.rb}'
end

task spec: [:spec_marionette]

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w[--markup=markdown]
end

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['--format=progress', 'features']
end

task :travis do
  if ENV['CAPYBARA_FF']
    Rake::Task[:spec_marionette].invoke
  else
    Rake::Task[:spec_chrome].invoke
  end
  Rake::Task[:cucumber].invoke
end

task :release do
  version = Capybara::VERSION
  puts "Releasing #{version}, y/n?"
  exit(1) unless STDIN.gets.chomp == 'y'
  sh "git commit -am 'tagged #{version}' && " \
     "git tag #{version} && " \
     'gem build capybara.gemspec && ' \
     "gem push capybara-#{version}.gem && " \
     'git push && ' \
     'git push --tags'
end

task default: %i[spec cucumber]
