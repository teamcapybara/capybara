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
      before do
        @session.click_button('awesome')
        @results = YAML.load(@session.body)
      end

      it "should serialize and submit text fields" do
        @results['first_name'].should == 'John'
      end

      it "should not serialize fields from other forms" do
        @results['middle_name'].should be_nil
      end

      it "should submit the button that was clicked, but not other buttons" do
        @results['awesome'].should == 'awesome'
        @results['crappy'].should be_nil
      end

      it "should serialize radio buttons" do
        @results['gender'].should == 'female'
      end

      it "should serialize check boxes" do
        @results['pets'].should include('dog', 'hamster')
        @results['pets'].should_not include('cat')
      end

      it "should serialize text areas" do
        @results['description'].should == 'Descriptive text goes here'
      end

      it "should serialize select tag with values" do
        @results['locale'].should == 'en'
      end

      it "should serialize select tag without values" do
        @results['region'].should == 'Norway'
      end

      it "should serialize first option for select tag with no selection" do
        @results['city'].should == 'London'
      end

      it "should not serialize a select tag without options" do
        @results['tendency'].should be_nil 
      end

      context "with multipart form" do
        it "should attach the file"
      end

      context "with normal form" do
        it "should serialize the file path"
      end
    end

    context "with id given" do
      it "should submit the associated form" do
        @session.click_button('awe123')
        results = YAML.load(@session.body)
        results['first_name'].should == 'John'
      end
    end
  end

  describe "#fill_in" do
    it "should fill in a field by id" do
      @session.visit('/form')
      @session.fill_in('form_first_name', :with => 'Harry')
      @session.click_button('awesome')
      YAML.load(@session.body)['first_name'].should == 'Harry'
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
