# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$:.unshift lib unless $:.include?(lib)

require 'capybara/version'

Gem::Specification.new do |s|
  s.name = 'capybara'
  s.version = Capybara::VERSION
  s.required_ruby_version = '>= 2.3.0'
  s.license = 'MIT'

  s.authors = ['Thomas Walpole', 'Jonas Nicklas']
  s.email = ['twalpole@gmail.com', 'jonas.nicklas@gmail.com']
  s.description = 'Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website'

  s.files = Dir.glob('{lib,spec}/**/*') + %w[README.md History.md License.txt]

  s.homepage = 'https://github.com/teamcapybara/capybara'
  s.metadata = {
    'changelog_uri' => 'https://github.com/teamcapybara/capybara/blob/master/History.md',
    'source_code_uri' => 'https://github.com/teamcapybara/capybara'
  }
  s.require_paths = ['lib']
  s.summary = 'Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb'

  s.add_runtime_dependency('addressable')
  s.add_runtime_dependency('mini_mime', ['>= 0.1.3'])
  s.add_runtime_dependency('nokogiri', ['~> 1.8'])
  s.add_runtime_dependency('rack', ['>= 1.6.0'])
  s.add_runtime_dependency('rack-test', ['>= 0.6.3'])
  s.add_runtime_dependency('xpath', ['~>3.1'])

  s.add_development_dependency('cucumber', ['>= 2.3.0'])
  s.add_development_dependency('erubi') # dependency specification needed by rbx
  s.add_development_dependency('fuubar', ['>= 1.0.0'])
  s.add_development_dependency('launchy', ['>= 2.0.4'])
  s.add_development_dependency('minitest')
  s.add_development_dependency('puma')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', ['>= 3.4.0'])
  s.add_development_dependency('selenium-webdriver', ['~>3.5'])
  s.add_development_dependency('sinatra', ['>= 1.4.0'])
  s.add_development_dependency('webdrivers') if ENV['CI']
  s.add_development_dependency('yard', ['>= 0.9.0'])

  if RUBY_ENGINE == 'rbx'
    s.add_development_dependency('json')
    s.add_development_dependency('racc')
    s.add_development_dependency('rubysl')
  end

  s.signing_key = 'gem-private_key.pem' if File.exist?('gem-private_key.pem')
  s.cert_chain = ['gem-public_cert.pem']
end
