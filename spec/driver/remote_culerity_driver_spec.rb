require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Culerity do
  before do
    @driver = Capybara::Driver::Culerity.new(TestApp)
  end
  
  before(:all) do
    Capybara.app_host = "http://capybara-testapp.heroku.com"
  end
  
  after(:all) do
    Capybara.app_host = nil
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
end