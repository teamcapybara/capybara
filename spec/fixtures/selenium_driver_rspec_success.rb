require 'spec_helper'
require 'capybara/selenium'

describe Capybara::Selenium::Driver do
  it "should exit with a zero exit status" do
    browser = Capybara::Selenium::Driver.new(TestApp).browser
    true.should == true
  end
end
