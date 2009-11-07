require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Webcat::Driver::Culerity do
  before do
    @driver = Webcat::Driver::Culerity.new(TestApp)
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
end
