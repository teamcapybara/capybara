require 'spec_helper'

describe Capybara::Session do
  context 'with selenium driver' do
    before do
      @session = TestSessions::Selenium
    end

    describe '#driver' do
      it "should be a selenium driver" do
        @session.driver.should be_an_instance_of(Capybara::Selenium::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :selenium
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session with javascript support"
    it_should_behave_like "session with screenshot support"
    it_should_behave_like "session with frame support"
    it_should_behave_like "session with window support"
    it_should_behave_like "session without headers support"
    it_should_behave_like "session without status code support"

    unless RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
      it "should not interfere with forking child processes" do
        # Launch a browser, which registers the at_exit hook
        browser = Capybara::Selenium::Driver.new(TestApp).browser

        # Fork an unrelated child process. This should not run the code in the at_exit hook.
        begin
          pid = fork { "child" }
          Process.wait2(pid)[1].exitstatus.should == 0
        rescue NotImplementedError
          # Fork unsupported (e.g. on JRuby)
        end

        browser.quit
      end
    end

    describe "exit codes" do
      before do
        @current_dir = Dir.getwd
        Dir.chdir(File.join(File.dirname(__FILE__), '..'))
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
end
