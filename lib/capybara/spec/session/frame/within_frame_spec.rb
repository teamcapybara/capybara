# frozen_string_literal: true

Capybara::SpecHelper.spec '#within_frame', requires: [:frames] do
  before do
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

  it "should find the div given selector and locator" do
    @session.within_frame(:css, '#frameOne') do
      expect(@session.find("//*[@id='divInFrameOne']").text).to eql 'This is the text of divInFrameOne'
    end
  end

  it "should default to the :frame selector kind when only options passed" do
    @session.within_frame(name: 'my frame one') do
      expect(@session.find("//*[@id='divInFrameOne']").text).to eql 'This is the text of divInFrameOne'
    end
  end

  it "should find multiple nested frames" do
    @session.within_frame 'parentFrame' do
      @session.within_frame 'childFrame' do
        @session.within_frame 'grandchildFrame1' do
          # dummy
        end
        @session.within_frame 'grandchildFrame2' do
          # dummy
        end
      end
    end
  end

  it "should reset scope when changing frames" do
    @session.within(:css, '#divInMainWindow') do
      @session.within_frame 'innerParentFrame' do
        expect(@session.has_selector?(:css, "iframe#childFrame")).to be true
      end
    end
  end

  it "works if the frame is closed", requires: %i[frames js] do
    @session.within_frame 'parentFrame' do
      @session.within_frame 'childFrame' do
        @session.click_link 'Close Window'
      end
      expect(@session).to have_selector(:css, 'body#parentBody')
      expect(@session).not_to have_selector(:css, '#childFrame')
    end
  end
end
