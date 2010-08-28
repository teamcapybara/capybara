require 'spec_helper'

describe Capybara::Driver::Selenium do
  before do
    @driver = TestSessions::Selenium.driver
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with frame support"
  it_should_behave_like "driver with support for window switching"
  it_should_behave_like "driver without status code support"
  it_should_behave_like "driver with cookies support"
end
