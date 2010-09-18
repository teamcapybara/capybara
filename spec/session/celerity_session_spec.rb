require 'spec_helper'

describe Capybara::Driver::Celerity, :jruby => :platform do
  before(:all) do
    @session = TestSessions::Celerity
  end

  describe '#driver' do
    it "should be a celerity driver" do
      @session.driver.should be_an_instance_of(Capybara::Driver::Celerity)
    end
  end

  describe '#mode' do
    it "should remember the mode" do
      @session.mode.should == :celerity
    end
  end

  it_should_behave_like "session"
  it_should_behave_like "session with javascript support"
  it_should_behave_like "session with headers support"
  it_should_behave_like "session with status code support"
end
