Capybara::SpecHelper.spec '#within_frame', :requires => [:frames] do
  before(:each) do
    @session.visit('/within_frames')
  end

  it "should find the div in frameOne" do
    @session.within_frame("frameOne") do
      @session.find("//*[@id='divInFrameOne']").text.should eql 'This is the text of divInFrameOne'
    end
  end
  it "should find the div in FrameTwo" do
    @session.within_frame("frameTwo") do
      @session.find("//*[@id='divInFrameTwo']").text.should eql 'This is the text of divInFrameTwo'
    end
  end
  it "should find the text div in the main window after finding text in frameOne" do
    @session.within_frame("frameOne") do
      @session.find("//*[@id='divInFrameOne']").text.should eql 'This is the text of divInFrameOne'
    end
    @session.find("//*[@id='divInMainWindow']").text.should eql 'This is the text for divInMainWindow'
  end
  it "should find the text div in the main window after finding text in frameTwo" do
    @session.within_frame("frameTwo") do
      @session.find("//*[@id='divInFrameTwo']").text.should eql 'This is the text of divInFrameTwo'
    end
    @session.find("//*[@id='divInMainWindow']").text.should eql 'This is the text for divInMainWindow'
  end
  it "should return the result of executing the block" do
    @session.within_frame("frameOne") { "return value" }.should eql "return value"
  end
end
