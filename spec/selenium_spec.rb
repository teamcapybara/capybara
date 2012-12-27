require 'spec_helper'

module TestSessions
  Selenium = Capybara::Session.new(:selenium, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Selenium, "selenium", :skip => [
  :response_headers,
  :status_code,
  :trigger
]

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
