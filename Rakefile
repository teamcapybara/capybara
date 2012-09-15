require 'rubygems'
require 'rspec/core/rake_task'
require 'yard'
require 'cucumber/rake/task'

task :default => [:spec, :cucumber]

desc 'Run all cucumber scenarios'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

desc "Run all spec examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  #t.rspec_path = 'bin/rspec'
  t.rspec_opts = %w[--color]
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'README.rdoc']
  #t.options = ['--any', '--extra', '--opts'] # optional
end

