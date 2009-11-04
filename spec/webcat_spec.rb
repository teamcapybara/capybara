require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Webcat::Session do
  before do
    @session = Webcat::Session.new(:rack_test, TestApp)
  end
  
  describe '#driver' do
    it "should be a rack test driver" do
      @session.driver.should be_an_instance_of(Webcat::Driver::RackTest)
    end
  end
  
  describe '#app' do
    it "should remember the application" do
      @session.app.should == TestApp
    end
  end

  describe '#mode' do
    it "should remember the mode" do
      @session.mode.should == :rack_test
    end
  end

  describe '#visit' do
    it "should fetch a response from the driver" do
      @session.visit('/')
      @session.body.should == 'Hello world!'
      @session.visit('/foo')
      @session.body.should == 'Another World'
    end
  end

end