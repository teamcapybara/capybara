module WithFrameSpec
    shared_examples_for "with_frame" do
        describe '#with_frame' do
            before(:each) do
                @driver.visit('/with_frames')
            end

            it "should find the div in frameOne" do
                @driver.with_frame("frameOne") do
                    @driver.find("//*[@id='divInFrameOne']")[0].text.should eql 'This is the text of divInFrameOne'
                end
            end
            it "should find the div in FrameTwo" do
                @driver.with_frame("frameTwo") do
                    @driver.find("//*[@id='divInFrameTwo']")[0].text.should eql 'This is the text of divInFrameTwo'
                end
            end
            it "should find the text div in the main window after finding text in frameOne" do
                @driver.with_frame("frameOne") do
                    @driver.find("//*[@id='divInFrameOne']")[0].text.should eql 'This is the text of divInFrameOne'
                end
                @driver.find("//*[@id='divInMainWindow']")[0].text.should eql 'This is the text for divInMainWindow'
            end
            it "should find the text div in the main window after finding text in frameTwo" do
                @driver.with_frame("frameTwo") do
                    @driver.find("//*[@id='divInFrameTwo']")[0].text.should eql 'This is the text of divInFrameTwo'
                end
                @driver.find("//*[@id='divInMainWindow']")[0].text.should eql 'This is the text for divInMainWindow'
            end
        end
    end
end