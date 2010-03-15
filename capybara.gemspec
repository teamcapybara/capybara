# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capybara}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = %q{2010-02-25}
  s.description = %q{Capybara aims to simplify the process of integration testing Rack applications,
such as Rails, Sinatra or Merb. It is inspired by and aims to replace Webrat as
a DSL for interacting with a webapplication. It is agnostic about the driver
running your tests and currently comes bundled with rack-test, Culerity,
Celerity and Selenium support built in.}
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "config.ru", "lib/capybara.rb", "lib/capybara/cucumber.rb", "lib/capybara/driver/base.rb", "lib/capybara/driver/celerity_driver.rb", "lib/capybara/driver/culerity_driver.rb", "lib/capybara/driver/rack_test_driver.rb", "lib/capybara/driver/selenium_driver.rb", "lib/capybara/dsl.rb", "lib/capybara/node.rb", "lib/capybara/rails.rb", "lib/capybara/save_and_open_page.rb", "lib/capybara/searchable.rb", "lib/capybara/server.rb", "lib/capybara/session.rb", "lib/capybara/wait_until.rb", "lib/capybara/xpath.rb", "script/console", "script/destroy", "script/generate", "spec/capybara_spec.rb", "spec/driver/celerity_driver_spec.rb", "spec/driver/culerity_driver_spec.rb", "spec/driver/rack_test_driver_spec.rb", "spec/driver/remote_culerity_driver_spec.rb", "spec/driver/remote_selenium_driver_spec.rb", "spec/driver/selenium_driver_spec.rb", "spec/drivers_spec.rb", "spec/dsl/all_spec.rb", "spec/dsl/attach_file_spec.rb", "spec/dsl/check_spec.rb", "spec/dsl/choose_spec.rb", "spec/dsl/click_button_spec.rb", "spec/dsl/click_link_spec.rb", "spec/dsl/click_spec.rb", "spec/dsl/current_url_spec.rb", "spec/dsl/fill_in_spec.rb", "spec/dsl/find_button_spec.rb", "spec/dsl/find_by_id_spec.rb", "spec/dsl/find_field_spec.rb", "spec/dsl/find_link_spec.rb", "spec/dsl/find_spec.rb", "spec/dsl/has_button_spec.rb", "spec/dsl/has_content_spec.rb", "spec/dsl/has_css_spec.rb", "spec/dsl/has_field_spec.rb", "spec/dsl/has_link_spec.rb", "spec/dsl/has_xpath_spec.rb", "spec/dsl/locate_spec.rb", "spec/dsl/select_spec.rb", "spec/dsl/uncheck_spec.rb", "spec/dsl/within_spec.rb", "spec/dsl_spec.rb", "spec/fixtures/capybara.jpg", "spec/fixtures/test_file.txt", "spec/public/jquery-ui.js", "spec/public/jquery.js", "spec/public/test.js", "spec/save_and_open_page_spec.rb", "spec/searchable_spec.rb", "spec/server_spec.rb", "spec/session/celerity_session_spec.rb", "spec/session/culerity_session_spec.rb", "spec/session/rack_test_session_spec.rb", "spec/session/selenium_session_spec.rb", "spec/session_spec.rb", "spec/session_with_headers_support_spec.rb", "spec/session_with_javascript_support_spec.rb", "spec/session_without_headers_support_spec.rb", "spec/session_without_javascript_support_spec.rb", "spec/spec_helper.rb", "spec/test_app.rb", "spec/views/buttons.erb", "spec/views/fieldsets.erb", "spec/views/form.erb", "spec/views/postback.erb", "spec/views/tables.erb", "spec/views/with_html.erb", "spec/views/with_js.erb", "spec/views/with_scope.erb", "spec/views/with_simple_html.erb", "spec/wait_until_spec.rb", "spec/xpath_spec.rb"]
  s.homepage = %q{http://github.com/jnicklas/capybara}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{capybara}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_runtime_dependency(%q<culerity>, [">= 0.2.4"])
      s.add_runtime_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rack-test>, [">= 0.5.2"])
      s.add_development_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<hoe>, [">= 2.5.0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<culerity>, [">= 0.2.4"])
      s.add_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<rack-test>, [">= 0.5.2"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<hoe>, [">= 2.5.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<culerity>, [">= 0.2.4"])
    s.add_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<rack-test>, [">= 0.5.2"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<hoe>, [">= 2.5.0"])
  end
end
