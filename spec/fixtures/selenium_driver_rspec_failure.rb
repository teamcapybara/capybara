require 'spec_helper'

describe Capybara::Selenium::Driver do
  it "should exit with a non-zero exit status" do
    browser = Capybara::Selenium::Driver.new(TestApp).browser
    true.should == false
  end
end
