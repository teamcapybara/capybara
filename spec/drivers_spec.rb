require File.expand_path('spec_helper', File.dirname(__FILE__))

shared_examples_for 'driver' do

  describe '#visit' do
    it "should move to another page" do
      @driver.visit('/')
      @driver.body.should include('Hello world!')
      @driver.visit('/foo')
      @driver.body.should include('Another World')
    end
  end

  describe '#body' do
    it "should return text reponses" do
      @driver.visit('/')
      @driver.body.should include('Hello world!')
    end

    it "should return the full response html" do
      @driver.visit('/with_simple_html')
      @driver.body.should include('<h1>Bar</h1>')
    end
  end

  describe '#find' do
    context "with xpath selector" do
      before do
        @driver.visit('/with_html')
      end

      it "should find the correct number of elements" do
        @driver.find('//a').size.should == 3
      end

      it "should extract node texts" do
        @driver.find('//a')[0].text.should == 'labore'
        @driver.find('//a')[1].text.should == 'ullamco'
      end
      
      it "should extract node attributes" do
        @driver.find('//a')[0][:href].should == '/with_simple_html'
        @driver.find('//a')[0][:class].should == 'simple'
        @driver.find('//a')[1][:href].should == '/foo'
        @driver.find('//a')[1][:id].should == 'foo'
        @driver.find('//a')[1][:rel].should be_nil
      end

      it "should allow assignment of field value" do
        @driver.find('//input').first.value.should == 'monkey'
        @driver.find('//input').first.set('gorilla')
        @driver.find('//input').first.value.should == 'gorilla'
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
  
  describe '#drag_to' do
    it "should drag and drop an object" do
      @driver.visit('/with_js')
      draggable = @driver.find('//div[@id="drag"]').first
      droppable = @driver.find('//div[@id="drop"]').first
      draggable.drag_to(droppable)
      @driver.find('//div[contains(., "Dropped!")]').should_not be_nil
    end
  end
end
