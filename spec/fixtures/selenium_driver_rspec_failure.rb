require 'spec_helper'

describe Capybara::Selenium::Driver do
  it "should exit with a non-zero exit status" do
    browser = Capybara::Selenium::Driver.new(TestApp).browser
    expect(true).to be false
  end
end
