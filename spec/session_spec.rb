require File.expand_path('spec_helper', File.dirname(__FILE__))

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
    before do
      @session.visit('/with_html')
    end

    context "with id given" do
      it "should take user to the linked page" do
        @session.click_link('foo')
        @session.body.should == 'Another World'
      end
    end
    
    context "with text given" do
      it "should take user to the linked page" do
        @session.click_link('labore')
        @session.body.should == '<h1>Bar</h1>'
      end
    end

    context "with title given" do
      it "should take user to the linked page" do
        @session.click_link('awesome title')
        @session.body.should == '<h1>Bar</h1>'
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.click_link('does not exist')
        end.should raise_error(Webcat::ElementNotFound)
      end
    end
  end

  describe '#click_button' do
    before do
      @session.visit('/form')
    end

    context "with value given" do
      it "should submit the associated form" do
        @session.click_button('awesome')
        results = YAML.load(@session.body)
        results['foo'].should == 'blah'
      end
    end
  end
end
  
describe Webcat::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      running {
        Webcat::Session.new(:quox, TestApp).driver
      }.should raise_error(Webcat::DriverNotFoundError)
    end
  end
end
