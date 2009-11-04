require File.expand_path('spec_helper', File.dirname(__FILE__))

shared_examples_for 'driver' do
  
  describe '#get' do
    it "should fetch a response" do
      @driver.visit('/')
      @driver.body.should == 'Hello world!'
      @driver.visit('/foo')
      @driver.body.should == 'Another World'
    end
  end
  
end