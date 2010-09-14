require 'capybara/spec/test_app'

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
      @driver.body.should include('Bar')
    end
  end

  describe '#find' do
    context "with xpath selector" do
      before do
        @driver.visit('/with_html')
      end

      it "should extract node texts" do
        @driver.find('//a')[0].text.should == 'labore'
        @driver.find('//a')[1].text.should == 'ullamco'
      end

      it "should extract node attributes" do
        @driver.find('//a')[0][:class].should == 'simple'
        @driver.find('//a')[1][:id].should == 'foo'
      end

      it "should extract boolean node attributes" do
        @driver.find('//input[@id="checked_field"]')[0][:checked].should be_true
      end

      it "should allow retrieval of the value" do
        @driver.find('//textarea').first.value.should == 'banana'
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
      pending "drag/drop is currently broken under celerity/culerity" if @driver.is_a?(Capybara::Driver::Celerity)
      draggable = @driver.find('//div[@id="drag"]').first
      droppable = @driver.find('//div[@id="drop"]').first
      draggable.drag_to(droppable)
      @driver.find('//div[contains(., "Dropped!")]').should_not be_empty
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

shared_examples_for "driver with status code support" do
  it "should make the status code available through status_code" do
    @driver.visit('/with_simple_html')
    @driver.status_code.should == 200
  end
end

shared_examples_for "driver without status code support" do
  it "should raise when trying to access the status code available through status_code" do
    @driver.visit('/with_simple_html')
    lambda {
      @driver.status_code
    }.should raise_error(Capybara::NotSupportedByDriverError)
  end
end

shared_examples_for "driver with window support" do
  describe '#attach' do
    before(:each) do 
      @driver.visit('/opens_window')
      @driver.find('//a')[0].click
    end

    it "should be able to attach by title" do
      @driver.attach(:title, "Opens Window")
      @driver.body.should include('Open a window')
      @driver.attach(:title, "Subwindow")
      @driver.body.should include('This is a sub-window')
    end

    it "should be able to attach by url" do
      @driver.attach(:url, "/opens_window")
      @driver.body.should include('Open a window')
      @driver.attach(:url, "/sub_window")
      @driver.body.should include('This is a sub-window')
    end

    it "should be able to attach by handle" do
      opens_window = @driver.attach(:title, "Opens Window")
      subwindow = @driver.attach(:title, "Subwindow")
      @driver.attach(:handle, opens_window)
      @driver.body.should include('Open a window')
      @driver.attach(:handle, subwindow)
      @driver.body.should include('This is a sub-window')
    end
  end

  describe '#click_and_attach' do
    before(:each) do 
      @driver.visit('/opens_window')
    end

    it "should attach to the new window" do
      @driver.body.should include('Open a window')
      @driver.find('//a')[0].click_and_attach
      @driver.body.should include('This is a sub-window')
    end
  end
end

shared_examples_for "driver with frame support" do
  describe '#within_frame' do
    before(:each) do
      @driver.visit('/within_frames')
    end

    it "should find the div in frameOne" do
      @driver.within_frame("frameOne") do
        @driver.find("//*[@id='divInFrameOne']")[0].text.should eql 'This is the text of divInFrameOne'
      end
    end
    it "should find the div in FrameTwo" do
      @driver.within_frame("frameTwo") do
        @driver.find("//*[@id='divInFrameTwo']")[0].text.should eql 'This is the text of divInFrameTwo'
      end
    end
    it "should find the text div in the main window after finding text in frameOne" do
      @driver.within_frame("frameOne") do
        @driver.find("//*[@id='divInFrameOne']")[0].text.should eql 'This is the text of divInFrameOne'
      end
      @driver.find("//*[@id='divInMainWindow']")[0].text.should eql 'This is the text for divInMainWindow'
    end
    it "should find the text div in the main window after finding text in frameTwo" do
      @driver.within_frame("frameTwo") do
        @driver.find("//*[@id='divInFrameTwo']")[0].text.should eql 'This is the text of divInFrameTwo'
      end
      @driver.find("//*[@id='divInMainWindow']")[0].text.should eql 'This is the text for divInMainWindow'
    end
  end
end

shared_examples_for "driver with cookies support" do
  describe "#cleanup" do
    it "should set and clean cookies" do
      @driver.visit('/get_cookie')
      @driver.body.should_not include('test_cookie')

      @driver.visit('/set_cookie')
      @driver.body.should include('Cookie set to test_cookie')

      @driver.visit('/get_cookie')
      @driver.body.should include('test_cookie')

      @driver.cleanup!
      @driver.visit('/get_cookie')
      @driver.body.should_not include('test_cookie')
    end
  end
end

shared_examples_for "driver with infinite redirect detection" do
  it "should follow 5 redirects" do
    @driver.visit('/redirect/5/times')
    @driver.body.should include('redirection complete')
  end

  it "should not follow more than 5 redirects" do
    running do
      @driver.visit('/redirect/6/times')
    end.should raise_error(Capybara::InfiniteRedirectError)
  end
end
