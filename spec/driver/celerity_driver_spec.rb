require 'spec_helper'

describe Capybara::Driver::Celerity, :jruby => :platform do
  before(:all) do
    @driver = TestSessions::Celerity.driver
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
end
