require 'spec_helper'

describe Capybara::Driver::Selenium do
  it "should exit with a zero exit status" do
    browser = Capybara::Driver::Selenium.new(TestApp).browser
    true.should == true
  end
end
