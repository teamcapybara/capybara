require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Selenium do
  before do
    @driver = Capybara::Driver::Selenium.new(TestApp)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver without node path support"
  it_should_behave_like "driver without direct HTTP support"
end
