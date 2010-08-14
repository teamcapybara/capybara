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

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.rdoc History.txt)
  s.extra_rdoc_files = ["README.rdoc"]

  s.homepage = "http://github.com/jnicklas/capybara"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.6"
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb"

  s.add_runtime_dependency("nokogiri", [">= 1.3.3"])
  s.add_runtime_dependency("mime-types", [">= 1.16"])
  s.add_runtime_dependency("culerity", [">= 0.2.4"])
  s.add_runtime_dependency("celerity", [">= 0.7.9"])
  s.add_runtime_dependency("selenium-webdriver", [">= 0.0.3"])
  s.add_runtime_dependency("rack", [">= 1.0.0"])
  s.add_runtime_dependency("rack-test", [">= 0.5.4"])

  s.add_development_dependency("sinatra", [">= 0.9.4"])
  s.add_development_dependency("rspec", [">= 1.2.9"])
  s.add_development_dependency("launchy", [">= 0.3.5"])
  s.add_development_dependency("yard", [">= 0.5.8"])
end
