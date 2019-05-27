# frozen_string_literal: true

require 'rubygems'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'yard'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run all examples with Firefox'

rspec_opts = %w[--color]

RSpec::Core::RakeTask.new(:spec_firefox) do |t|
  t.rspec_opts = rspec_opts
  t.pattern = './spec{,/*/**}/*{_spec.rb,_spec_firefox.rb}'
end

%w[chrome ie edge chrome_remote firefox_remote safari].each do |driver|
  RSpec::Core::RakeTask.new(:"spec_#{driver}") do |t|
    t.rspec_opts = rspec_opts
    t.pattern = "./spec/{selenium_spec_#{driver}.rb}"
  end
end

RSpec::Core::RakeTask.new(:spec_sauce) do |t|
  t.rspec_opts = rspec_opts
  t.pattern = './spec/sauce_spec_chrome.rb'
end

# RSpec::Core::RakeTask.new(:spec_rack, [] => :rubocop) do |t|
RSpec::Core::RakeTask.new(:spec_rack) do |t|
  t.rspec_opts = rspec_opts
  t.pattern = './spec{,/*/**}/*{_spec.rb}'
end

task spec: [:spec_firefox]

task rack_smoke: %i[rubocop spec_rack]

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['--format=progress', 'features']
end

task :travis do
  if ENV['CAPYBARA_REMOTE'] && ENV['CAPYBARA_FF']
    Rake::Task[:spec_firefox_remote].invoke
  elsif ENV['CAPYBARA_FF']
    Rake::Task[:spec_firefox].invoke
  elsif ENV['CAPYBARA_IE']
    Rake::Task[:spec_ie].invoke
  elsif ENV['CAPYBARA_EDGE']
    Rake::Task[:spec_edge].invoke
  elsif ENV['CAPYBARA_REMOTE']
    Rake::Task[:spec_chrome_remote].invoke
  else
    Rake::Task[:spec_chrome].invoke
  end
  Rake::Task[:cucumber].invoke
end

task :build_js do
  require 'uglifier'
  Dir.glob('./lib/capybara/selenium/atoms/src/*.js').each do |fn|
    js = ::Uglifier.compile(
      File.read(fn),
      compress: {
        negate_iife: false, # Negate immediately invoked function expressions to avoid extra parens
        side_effects: false # Pass false to disable potentially dropping functions marked as "pure"
      }
    )[0...-1]
    File.write("./lib/capybara/selenium/atoms/#{File.basename(fn).gsub('.js', '.min.js')}", js)
  end
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
