require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Webcat::Driver::RackTest do
  before do
    @driver = Webcat::Driver::RackTest.new(TestApp)
  end
  
  it_should_behave_like "driver"
end
