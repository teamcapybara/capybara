require 'spec_helper'

describe Capybara::Driver::Selenium do
  before do
    #Capybara.app_host = "http://capybara-testapp.heroku.com"
    @driver = TestSessions::Selenium.driver
  end

  after do
    Capybara.app_host = nil
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver without status code support"
end
