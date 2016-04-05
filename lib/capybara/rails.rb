# frozen_string_literal: true
require 'capybara/dsl'

Capybara.app = Rack::Builder.new do
  map "/" do
    if Gem::Version.new(Rails.version) >= Gem::Version.new("3.0")
      run Rails.application
    else # Rails 2
      use Rails::Rack::Static
      run ActionController::Dispatcher.new
    end
  end
end.to_app

Capybara.save_path = Rails.root.join('tmp/capybara')

# Override default rack_test driver to respect data-method attributes.
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :respect_data_method => true)
end
