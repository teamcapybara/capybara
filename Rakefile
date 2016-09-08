require 'rubygems'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'yard'
require_relative './.yard/yard_extensions'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  # When we drop RSpec 2.x support we can rename spec_chrome.rb and implement this properly
  # t.exclude_pattern = './spec/*{_chrome_spec.rb}'
end

RSpec::Core::RakeTask.new(:all) do |t|
  t.rspec_opts = %w[--color]
  # jruby buffers the progress formatter so travis doesn't see output often enough
  t.rspec_opts << '--format documentation' if RUBY_PLATFORM=='java'
  t.pattern = './spec{,/*/**}/*{_spec.rb,_spec_chrome.rb}'
end

RSpec::Core::RakeTask.new(:spec_chrome) do |t|
  t.rspec_opts = %w[--color]
  # jruby buffers the progress formatter so travis doesn't see output often enough
  t.rspec_opts << '--format documentation' if RUBY_PLATFORM=='java'
  t.pattern = './spec/*{_spec_chrome.rb}'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w(--markup=markdown)
end

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['--format=progress', 'features']
end

task :travis do |t|
  if ENV['CAPYBARA_CHROME']
    Rake::Task[:spec_chrome].invoke
  else
    Rake::Task[:spec].invoke
    Rake::Task[:cucumber].invoke
  end
end

task :default => [:spec, :cucumber]
