# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift "lib"

require "capybara-patch"

Gem::Specification.new do |s|

  s.name        = "capybara-patch"
  s.version     = CapybaraPatch::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paperless Post"]
  s.email       = "dev@paperlesspost.com"
  s.licenses    = ["MIT"]
  s.homepage    = "http://github.com/paperlesspost/capybara"
  s.summary     = "Patches for capybara"
  s.description = "Patches for capybara gem"

  s.add_development_dependency("cucumber", "~> 0.10", ">= 0.10.5")
  s.add_development_dependency("pry", "~> 0.10", ">= 0.10.1")
  s.add_development_dependency("rake", "~> 10.4", ">= 10.4.2")
  s.add_development_dependency("rspec", "~> 2.2", ">= 2.2.0")
  s.add_development_dependency("selenium-webdriver", "2.0")
  s.add_development_dependency("sinatra", "~> 0.9", ">= 0.9.4")
  s.add_development_dependency("launchy", "~> 2.0", ">= 2.0.4")
  s.add_development_dependency("fuubar", "~> 0.0", ">= 0.0.1")

  s.add_runtime_dependency("capybara", "~> 2.4", ">= 2.4.4")
  s.add_runtime_dependency("wait", "~> 0.5", ">= 0.5.2")

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "capybara-patch"

  s.files        = Dir.glob("{lib}/**/*") + Dir.glob("{test}/**/*") + %w(Rakefile Gemfile README.md)
  s.require_path = "lib"

end
