require 'spec_helper'

describe Capybara::Driver::Culerity, :jruby => :installed do

  before(:all) do
    @driver = TestSessions::Culerity.driver
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
end
