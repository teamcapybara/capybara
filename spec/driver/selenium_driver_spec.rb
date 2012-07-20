require 'spec_helper'
require 'rbconfig'

describe Capybara::Selenium::Driver do
  before do
    @driver = TestSessions::Selenium.driver
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with resynchronization support"
  it_should_behave_like "driver with frame support"
  it_should_behave_like "driver with support for window switching"
  it_should_behave_like "driver without status code support"
  it_should_behave_like "driver with cookies support"

  describe "exit codes" do
    before do
      @current_dir = Dir.getwd
      Dir.chdir(File.join(File.dirname(__FILE__), '..', '..'))
    end

    after do
      Dir.chdir(@current_dir)
    end

    it "should have return code 1 when running selenium_driver_rspec_failure.rb" do
      `rspec spec/fixtures/selenium_driver_rspec_failure.rb`
      $?.exitstatus.should be 1
    end

    it "should have return code 0 when running selenium_driver_rspec_success.rb" do
      `rspec spec/fixtures/selenium_driver_rspec_success.rb`
      $?.exitstatus.should be 0
    end
  end
end
