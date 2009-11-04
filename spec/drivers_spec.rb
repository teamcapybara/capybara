require File.expand_path('spec_helper', File.dirname(__FILE__))

shared_examples_for 'driver' do
  
  describe '#visit' do
    it "should move to another page" do
      @driver.visit('/')
      @driver.body.should == 'Hello world!'
      @driver.visit('/foo')
      @driver.body.should == 'Another World'
    end
  end
  
  describe '#body' do
    it "should return text reponses" do
      @driver.visit('/')
      @driver.body.should == 'Hello world!'
    end
    
    it "should return the full response html" do
      @driver.visit('/with_simple_html')
      @driver.body.should == '<h1>Bar</h1>'
    end
  end
  
end