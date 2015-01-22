require 'rubygems'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  #t.rspec_path = 'bin/rspec'
  t.rspec_opts = %w[--color]
end

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['--format=progress', 'features']
end

task :default => [:spec, :cucumber]
