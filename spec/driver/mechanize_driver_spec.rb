# encoding: utf-8
require 'spec_helper'

describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::Mechanize.driver
  end

  it "should throw an error when no rack app is given" do
    running do
      Capybara::RackTest::Driver.new(nil)
    end.should raise_error(ArgumentError)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"

end
