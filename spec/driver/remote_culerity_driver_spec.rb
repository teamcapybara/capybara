require 'spec_helper'

describe Capybara::Driver::Culerity, :jruby => :installed do
  before(:all) do
    Capybara.app_host = "http://capybara-testapp.heroku.com"
    @driver = TestSessions::Culerity.driver
  end

  after(:all) do
    Capybara.app_host = nil
  end

  it "should navigate to a fully qualified remote page" do
    @driver.visit('http://capybara-testapp.heroku.com/foo')
    @driver.body.should include('Another World')
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
end
