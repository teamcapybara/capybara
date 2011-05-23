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

  unless Config::CONFIG['host_os'] =~ /mswin|mingw/
    it "should not interfere with forking child processes" do
      # Launch a browser, which registers the at_exit hook
      browser = Capybara::Selenium::Driver.new(TestApp).browser

      # Fork an unrelated child process. This should not run the code in the at_exit hook.
      pid = fork { "child" }
      Process.wait2(pid)[1].exitstatus.should == 0

      browser.quit
    end
  end
end
