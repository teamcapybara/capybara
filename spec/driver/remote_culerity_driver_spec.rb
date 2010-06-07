require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Culerity do
  before(:all) do
    Capybara.app_host = "http://capybara-testapp.heroku.com"
    Capybara.run_server = false
    @driver = Capybara::Driver::Culerity.new(TestApp)
  end
  
  after(:all) do
    Capybara.app_host = nil
    Capybara.run_server = true
  end

  it "should navigate to a fully qualified remote page" do
    @driver.visit('http://elabs.se/contact')
    @driver.body.should include('Edithouse eLabs AB')
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
end
