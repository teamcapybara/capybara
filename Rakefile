require 'rubygems'
require 'spec/rake/spectask'
require 'yard'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'README.rdoc']
  #t.options = ['--any', '--extra', '--opts'] # optional
end

task :default => :spec
