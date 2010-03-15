require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::RackTest do
  before do
    @driver = Capybara::Driver::RackTest.new(TestApp)
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with node path support"
  it_should_behave_like "driver with direct HTTP support"
end
