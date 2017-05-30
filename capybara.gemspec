# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'capybara/version'

Gem::Specification.new do |s|
  s.name = "capybara"
  s.version = Capybara::VERSION
  s.required_ruby_version = ">= 1.9.3"
  s.license = "MIT"

  s.authors = ["Thomas Walpole", "Jonas Nicklas"]
  s.email = ["twalpole@gmail.com", "jonas.nicklas@gmail.com"]
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website"

  s.files = Dir.glob("{lib,spec,.yard}/**/*") + %w(README.md History.md License.txt .yardopts)

  s.homepage = "https://github.com/teamcapybara/capybara"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.6"
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb"

  s.add_runtime_dependency("nokogiri", [">= 1.6.6.4"])
  s.add_runtime_dependency("mime-types", [">= 1.16"])
  s.add_runtime_dependency("rack", [">= 1.0.0"])
  s.add_runtime_dependency("rack-test", [">= 0.5.4"])
  s.add_runtime_dependency("xpath", ["~> 2.0"])
  s.add_runtime_dependency("addressable")

  s.add_development_dependency("selenium-webdriver", [">= 2.0", "< 4.0"])
  s.add_development_dependency("sinatra", [">= 0.9.4"])
  s.add_development_dependency("rspec", [">= 2.2.0"])
  s.add_development_dependency("launchy", [">= 2.0.4"])
  s.add_development_dependency("yard", [">= 0.5.8"])
  s.add_development_dependency("fuubar", [">= 0.0.1"])
  s.add_development_dependency("cucumber", [">= 0.10.5"])
  s.add_development_dependency("minitest")
  s.add_development_dependency("rake")
  s.add_development_dependency("pry")
  s.add_development_dependency("erubi")  # dependency specification needed by rbx

  if RUBY_ENGINE == 'rbx' then
    s.add_development_dependency("racc")
    s.add_development_dependency("json")
    s.add_development_dependency("rubysl")
  end

  if File.exist?("gem-private_key.pem")
    s.signing_key = 'gem-private_key.pem'
  end
  s.cert_chain = ['gem-public_cert.pem']
end
