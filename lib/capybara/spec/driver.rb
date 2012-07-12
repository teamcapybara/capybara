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
        @driver.find('//textarea[@id="normal"]').first.value.should == 'banana'
      end

      it "should not swallow extra newlines in textarea" do
        @driver.find('//textarea[@id="additional_newline"]').first.value.should == "\nbanana"
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

      it "should return document text on /html selector" do
        @driver.visit('/with_simple_html')
        @driver.find('/html')[0].text.should == 'Bar'
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
      @driver.find('//div[contains(., "Dropped!")]').should_not be_empty
    end
  end

  describe "#evaluate_script" do
    it "should return the value of the executed script" do
      @driver.evaluate_script('1+1').should == 2
    end
  end

  describe '#set' do
    describe 'on a textfield' do
      it 'should only trigger onchange once' do
        field = @driver.find('//input[@id="with_change_event"]').first
        field.set('some value')
        field.value.should == 'some value'
      end
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
    it "should return the result of executing the block" do
      @driver.within_frame("frameOne") { "return value" }.should eql "return value"
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
  context "with default redirect limit" do
    let(:default_limit) { Capybara.redirect_limit }
    it "should follow #{Capybara.redirect_limit} redirects" do
      @driver.visit("/redirect/#{default_limit}/times")
      @driver.body.should include('redirection complete')
    end

    it "should not follow more than #{Capybara.redirect_limit} redirects" do
      running do
        @driver.visit("/redirect/#{default_limit + 1}/times")
      end.should raise_error(Capybara::InfiniteRedirectError)
    end
  end
  context "with 21 redirect limit" do
    let(:custom_limit) { 21 }
    around(:each) do |example|
      default_limit = Capybara.redirect_limit
      Capybara.redirect_limit= custom_limit
      example.run
      Capybara.redirect_limit= default_limit
    end
    it "should follow 21 redirects" do
      @driver.visit("/redirect/#{custom_limit}/times")
      @driver.body.should include('redirection complete')
    end

    it "should not follow more than 21 redirects" do
      running do
        @driver.visit("/redirect/#{custom_limit + 1}/times")
      end.should raise_error(Capybara::InfiniteRedirectError)
    end
  end
end

shared_examples_for "driver with referer support" do
  before :each do
    @driver.reset!
  end

  it "should send no referer when visiting a page" do
    @driver.visit '/get_referer'
    @driver.body.should include 'No referer'
  end

  it "should send no referer when visiting a second page" do
    @driver.visit '/get_referer'
    @driver.visit '/get_referer'
    @driver.body.should include 'No referer'
  end

  it "should send a referer when following a link" do
    @driver.visit '/referer_base'
    @driver.find('//a[@href="/get_referer"]').first.click
    @driver.body.should match %r{http://.*/referer_base}
  end

  it "should preserve the original referer URL when following a redirect" do
    @driver.visit('/referer_base')
    @driver.find('//a[@href="/redirect_to_get_referer"]').first.click
    @driver.body.should match %r{http://.*/referer_base}
  end

  it "should send a referer when submitting a form" do
    @driver.visit '/referer_base'
    @driver.find('//input').first.click
    @driver.body.should match %r{http://.*/referer_base}
  end
end

shared_examples_for "driver with screenshot support" do
  describe '#save_screenshot' do
    let(:image_path) { File.join(Dir.tmpdir, 'capybara-screenshot.png') }

    before do
      @driver.visit '/'
      @driver.save_screenshot image_path
    end

    it "should generate PNG file" do
      magic = File.read(image_path, 4)
      magic.should eq "\x89PNG"
    end
  end
end
