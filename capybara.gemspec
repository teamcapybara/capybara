# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'capybara/version'

Gem::Specification.new do |s|
  s.name = "capybara"
  s.rubyforge_project = "capybara"
  s.version = Capybara::VERSION

  s.authors = ["Jonas Nicklas"]
  s.email = ["jonas.nicklas@gmail.com"]
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website"

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md History.md License.txt)

  s.homepage = "http://github.com/jnicklas/capybara"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.6.paperless"
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb"

  s.add_runtime_dependency("capybara", ["2.4.4"])
  s.add_runtime_dependency("wait", ["~> 0.5"])

  s.add_development_dependency("sinatra", [">= 0.9.4"])
  s.add_development_dependency("rspec", [">= 2.2.0"])
  s.add_development_dependency("launchy", [">= 2.0.4"])
  s.add_development_dependency("yard", [">= 0.5.8"])
  s.add_development_dependency("fuubar", [">= 0.0.1"])
  s.add_development_dependency("cucumber", [">= 0.10.5"])
  s.add_development_dependency("rake")
end
