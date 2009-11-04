require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Webcat::Session do
  shared_examples_for "session" do
    describe '#app' do
      it "should remember the application" do
        @session.app.should == TestApp
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
    
    describe '#click_link' do
      context "with id given" do
        it "should take user to the linked page" do
          @session.visit('/with_html')
          @session.click_link('foo')
          @session.body.should == 'Another World'
        end
      end
    end
  end
  
  context 'with rack test driver' do
    before do
      @session = Webcat::Session.new(:rack_test, TestApp)
    end
  
    describe '#driver' do
      it "should be a rack test driver" do
        @session.driver.should be_an_instance_of(Webcat::Driver::RackTest)
      end
    end
    
    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :rack_test
      end
    end
    
    it_should_behave_like "session"
  end
  
  context 'with culerity driver' do
    before do
      @session = Webcat::Session.new(:culerity, TestApp)
    end
  
    describe '#driver' do
      it "should be a rack test driver" do
        @session.driver.should be_an_instance_of(Webcat::Driver::Culerity)
      end
    end
    
    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :culerity
      end
    end
    
    it_should_behave_like "session"
  end
  
  context 'with non-existent driver' do
    it "should raise an error" do
      running {
        Webcat::Session.new(:quox, TestApp).driver
      }.should raise_error(Webcat::DriverNotFoundError)
    end
  end

end