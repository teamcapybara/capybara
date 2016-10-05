# frozen_string_literal: true
Capybara::SpecHelper.spec '#within_frame', requires: [:frames] do
  before(:each) do
    @session.visit('/within_frames')
  end

  it "should find the div in frameOne" do
    @session.within_frame("frameOne") do
      expect(@session.find("//*[@id='divInFrameOne']").text).to eql 'This is the text of divInFrameOne'
    end
  end

  it "should find the div in FrameTwo" do
    @session.within_frame("frameTwo") do
      expect(@session.find("//*[@id='divInFrameTwo']").text).to eql 'This is the text of divInFrameTwo'
    end
  end

  it "should find the text div in the main window after finding text in frameOne" do
    @session.within_frame("frameOne") do
      expect(@session.find("//*[@id='divInFrameOne']").text).to eql 'This is the text of divInFrameOne'
    end
    expect(@session.find("//*[@id='divInMainWindow']").text).to eql 'This is the text for divInMainWindow'
  end

  it "should find the text div in the main window after finding text in frameTwo" do
    @session.within_frame("frameTwo") do
      expect(@session.find("//*[@id='divInFrameTwo']").text).to eql 'This is the text of divInFrameTwo'
    end
    expect(@session.find("//*[@id='divInMainWindow']").text).to eql 'This is the text for divInMainWindow'
  end

  it "should return the result of executing the block" do
    expect(@session.within_frame("frameOne") { "return value" }).to eql "return value"
  end

  it "should find the div given Element" do
    element = @session.find(:id, 'frameOne')
    @session.within_frame element do
      expect(@session.find("//*[@id='divInFrameOne']").text).to eql 'This is the text of divInFrameOne'
    end
  end

  it "should find multiple nested frames" do
    @session.within_frame 'parentFrame' do
      @session.within_frame 'childFrame' do
        @session.within_frame 'grandchildFrame1' do end
        @session.within_frame 'grandchildFrame2' do end
      end
    end
  end

  it "should reset scope when changing frames" do
    @session.within(:css, '#divInMainWindow') do
      @session.within_frame 'parentFrame' do
        expect(@session.has_selector?(:css, "iframe#childFrame")).to be true
      end
    end
  end

  it "works if the frame is closed", requires: [:frames, :js] do
    @session.within_frame 'parentFrame' do
      @session.within_frame 'childFrame' do
        @session.click_link 'Close Window'
      end
      expect(@session).to have_selector(:css, 'body#parentBody')
      expect(@session).not_to have_selector(:css, '#childFrame')
    end
  end

  it "should support the driver #switch_to_frame api" do
    # This test is purely to notify driver authors to update their API.
    # The #switch_to_frame API will be required in the next version (> 2.8) of Capybara for frames support.
    # It should not be used as an example of code for users.
    frame = @session.find(:frame, "frameOne")
    expect {
      @session.driver.switch_to_frame(frame)
      sleep 0.5
      @session.driver.switch_to_frame(:parent)
    }.not_to raise_error
  end
end
