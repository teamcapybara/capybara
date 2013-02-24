# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'capybara/version'

Gem::Specification.new do |s|
  s.name = "capybara"
  s.rubyforge_project = "capybara"
  s.version = Capybara::VERSION
  s.required_ruby_version = ">= 1.9.0"

  s.authors = ["Jonas Nicklas"]
  s.email = ["jonas.nicklas@gmail.com"]
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website"

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md History.md License.txt)

  s.homepage = "http://github.com/jnicklas/capybara"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.6"
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb"

  s.add_runtime_dependency("nokogiri", [">= 1.3.3"])
  s.add_runtime_dependency("mime-types", [">= 1.16"])
  s.add_runtime_dependency("rack", [">= 1.0.0"])
  s.add_runtime_dependency("rack-test", [">= 0.5.4"])
  s.add_runtime_dependency("xpath", ["~> 1.0.0"])

  s.add_development_dependency("selenium-webdriver", ["~> 2.0"])
  s.add_development_dependency("sinatra", [">= 0.9.4"])
  s.add_development_dependency("rspec", [">= 2.2.0"])
  s.add_development_dependency("launchy", [">= 2.0.4"])
  s.add_development_dependency("yard", [">= 0.5.8"])
  s.add_development_dependency("fuubar", [">= 0.0.1"])
  s.add_development_dependency("cucumber", [">= 0.10.5"])
  s.add_development_dependency("rake")
  s.add_development_dependency("pry")

  if File.exist?("gem-private_key.pem")
    s.signing_key = 'gem-private_key.pem'
  else
    puts "WARNING!! No private key specified, gem will not be signed!"
  end
  s.cert_chain = ['gem-public_cert.pem']
end
