require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Webcat::Session do
  context 'with selenium driver' do
    before do
      @session = Webcat::Session.new(:selenium, TestApp)
    end
  
    describe '#driver' do
      it "should be a rack test driver" do
        @session.driver.should be_an_instance_of(Webcat::Driver::Selenium)
      end
    end
    
    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :selenium
      end
    end
    
    it_should_behave_like "session"
  end
end
