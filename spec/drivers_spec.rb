require File.expand_path('spec_helper', File.dirname(__FILE__))

shared_examples_for 'driver' do

  describe '#visit' do
    it "should move to another page" do
      @driver.visit('/')
      @driver.body.should include('Hello world!')
      @driver.visit('/foo')
      @driver.body.should include('Another World')
    end
    
    it "should show the correct URL" do
      @driver.visit('/foo')
      @driver.current_url.should include('/foo')
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
      
      it "should extract node visibility" do
        @driver.find('//a')[0].should be_visible
        
        @driver.find('//div[@id="hidden"]')[0].should_not be_visible
        @driver.find('//div[@id="hidden_via_ancestor"]')[0].should_not be_visible
      end
    end
  end

end

shared_examples_for "driver with javascript support" do
  before { @driver.visit('/with_js') }

  describe '#find' do
    it "should find dynamically changed nodes" do
      @driver.find('//p').first.text.should == 'I changed it'
    end
  end

  describe '#drag_to' do
    it "should drag and drop an object" do
      draggable = @driver.find('//div[@id="drag"]').first
      droppable = @driver.find('//div[@id="drop"]').first
      draggable.drag_to(droppable)
      @driver.find('//div[contains(., "Dropped!")]').should_not be_nil
    end
  end

  describe "#evaluate_script" do
    it "should return the value of the executed script" do
      @driver.evaluate_script('1+1').should == 2
    end
  end

end

shared_examples_for "driver with header support" do
  it "should make headers available through response_headers" do
    @driver.visit('/with_simple_html')
    @driver.response_headers['Content-Type'].should == 'text/html'
  end
end

shared_examples_for "driver with node path support" do
  describe "node relative searching" do
    before do
      @driver.visit('/tables')
      @node = @driver.find('//body').first
    end
  
    it "should be able to navigate/search child nodes" do
      @node.all('//table').size.should == 3
      @node.find('//form').all('//table').size.should == 1
      @node.find('//form').find('//table//caption').text.should == 'Agent'
    end
  end
end

shared_examples_for "driver without node path support" do
  describe "node relative searching" do
    before do
      @driver.visit('/tables')
      @node = @driver.find('//body').first
    end
  
    it "should get NotSupportedByDriverError" do
      running do
        @node.all('//form')
      end.should raise_error(Capybara::NotSupportedByDriverError) 
    end
    
  end
end
