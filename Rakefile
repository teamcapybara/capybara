require 'rubygems'
require 'rspec/core/rake_task'
require 'yard'

desc "Run all examples"
RSpec::Core::RakeTask.new('spec')

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'README.rdoc']
  #t.options = ['--any', '--extra', '--opts'] # optional
end

task :default => :spec
