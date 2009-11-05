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

  describe '#find' do
    context "with xpath selector" do
      before do
        @driver.visit('/with_html')
      end

      it "should find the correct number of elements" do
        @driver.find('//a').size.should == 2
      end

      it "should extract node texts" do
        @driver.find('//a')[0].text.should == 'labore'
        @driver.find('//a')[1].text.should == 'ullamco'
      end
      
      it "should extract node attributes" do
        @driver.find('//a')[0].attribute(:href).should == '/with_simple_html'
        @driver.find('//a')[0].attribute(:class).should == 'simple'
        @driver.find('//a')[1].attribute(:href).should == '/foo'
        @driver.find('//a')[1].attribute(:id).should == 'foo'
        @driver.find('//a')[1].attribute(:rel).should be_nil
      end
      
      it "should extract node tag name" do
        @driver.find('//a')[0].tag_name.should == 'a'
        @driver.find('//a')[1].tag_name.should == 'a'
        @driver.find('//p')[1].tag_name.should == 'p'
      end
    end
  end

end

shared_examples_for "driver with javascript support" do
  describe '#find' do
    it "should find dynamically changed nodes" do
      @driver.visit('/with_js')
      @driver.find('//p').first.text.should == 'I changed it'
    end
  end
end
