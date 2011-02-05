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

    if "".respond_to?(:encoding)
      context "encoding of response between ascii and utf8" do
        it "should be valid with html entities" do
          @driver.visit('/with_html_entities')
          lambda { @driver.body.encode!("UTF-8") }.should_not raise_error
        end

        it "should be valid without html entities" do
          @driver.visit('/with_html')
          lambda { @driver.body.encode!("UTF-8") }.should_not raise_error
        end
      end
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
        @driver.find('//input')[0][:type].should == 'text'
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

      it "should extract node checked state" do
        @driver.visit('/form')
        @driver.find('//input[@id="gender_female"]')[0].should be_checked
        @driver.find('//input[@id="gender_male"]')[0].should_not be_checked
        @driver.find('//h1')[0].should_not be_checked
      end

      it "should extract node selected state" do
        @driver.visit('/form')
        @driver.find('//option[@value="en"]')[0].should be_selected
        @driver.find('//option[@value="sv"]')[0].should_not be_selected
        @driver.find('//h1')[0].should_not be_selected
      end
    end
  end
end

shared_examples_for "driver with local server" do
  describe "Capybara.app_host" do
    after(:each) { Capybara.app_host = nil } # reset app_host back to nil
    def match_path(host, path)
      match(%r{http://#{host}(:\d+)?#{path}})
    end
    def match_default_path(path)
      match_path "(127.0.0.1|www.example.com)", path
    end
    describe "set to custom host" do
      before { Capybara.app_host = 'http://foo.lvh.me' }
      it "should prefix urls with Capybara.app_host if app_host is set" do
        @driver.visit('/request_info')
        @driver.current_url.should match_path('foo.lvh.me', '/request_info')
      end
      it "should use the url in request data" do
        @driver.visit('/request_info')
        @driver.body.should include "http://foo.lvh.me"
      end
      # 
      it "forms should GET to Capybara.app_host" do
        @driver.visit('/form')
        @driver.current_url.should match_path('foo.lvh.me', '/form')
              
        @driver.find('//input[@id = "mediocre"]').first.click
        @driver.current_url.should match_path('foo.lvh.me', '/form/get')
      end
      it "can be changed during test" do
        @driver.visit('/request_info')
        Capybara.app_host = 'http://foo2.lvh.me'
        @driver.visit('/request_info')
        @driver.body.should include "foo2.lvh.me"
      end
      it 'can be reseted to nil during test' do
        @driver.visit('/')
        Capybara.app_host = nil
        @driver.visit('/form')
        @driver.current_url.should_not match_path('foo.lvh.me', '/')
      end
    end

    describe "set to nil" do
      it "should not prefix urls with Capybara.app_host" do
        @driver.visit('/')
        @driver.current_url.should match_default_path('/')
      end
      # 
      it "forms should POST normally" do
        @driver.visit('/form')
        @driver.current_url.should match_default_path('/form')
              
        @driver.find('//input[@id = "mediocre"]').first.click
        @driver.current_url.should match_default_path('/form/get')
      end
      it "can be changed during test" do
        @driver.visit('/')
        Capybara.app_host = 'http://foo2.lvh.me'
        @driver.visit('/request_info')
        @driver.body.should include "foo2.lvh.me"
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
    @driver.response_headers['Content-Type'].should =~ /text\/html/
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

shared_examples_for "driver with support for window switching" do
  describe '#within_window' do
    before(:each) do
      @driver.visit('/within_popups')
    end
    after(:each) do
      @driver.within_window("firstPopup") do
        @driver.evaluate_script('window.close()')
      end
      @driver.within_window("secondPopup") do
        @driver.evaluate_script('window.close()')
      end
    end

    it "should find the div in firstPopup" do
      @driver.within_window("firstPopup") do
        @driver.find("//*[@id='divInPopupOne']")[0].text.should eql 'This is the text of divInPopupOne'
      end
    end
    it "should find the div in secondPopup" do
      @driver.within_window("secondPopup") do
        @driver.find("//*[@id='divInPopupTwo']")[0].text.should eql 'This is the text of divInPopupTwo'
      end
    end
    it "should find the divs in both popups" do
      @driver.within_window("secondPopup") do
        @driver.find("//*[@id='divInPopupTwo']")[0].text.should eql 'This is the text of divInPopupTwo'
      end
      @driver.within_window("firstPopup") do
        @driver.find("//*[@id='divInPopupOne']")[0].text.should eql 'This is the text of divInPopupOne'
      end
    end
    it "should find the div in the main window after finding a div in a popup" do
      @driver.within_window("secondPopup") do
        @driver.find("//*[@id='divInPopupTwo']")[0].text.should eql 'This is the text of divInPopupTwo'
      end
      @driver.find("//*[@id='divInMainWindow']")[0].text.should eql 'This is the text for divInMainWindow'
    end
  end
end

shared_examples_for "driver with cookies support" do
  describe "#reset!" do
    it "should set and clean cookies" do
      @driver.visit('/get_cookie')
      @driver.body.should_not include('test_cookie')

      @driver.visit('/set_cookie')
      @driver.body.should include('Cookie set to test_cookie')

      @driver.visit('/get_cookie')
      @driver.body.should include('test_cookie')

      @driver.reset!
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
