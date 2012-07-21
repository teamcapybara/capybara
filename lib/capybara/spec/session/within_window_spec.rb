Capybara::SpecHelper.spec '#within_window', :requires => [:windows] do
  before(:each) do
    @session.visit('/within_popups')
  end
  after(:each) do
    @session.within_window("firstPopup") do
      @session.evaluate_script('window.close()')
    end
    @session.within_window("secondPopup") do
      @session.evaluate_script('window.close()')
    end
  end

  it "should find the div in firstPopup" do
    @session.within_window("firstPopup") do
      @session.find("//*[@id='divInPopupOne']").text.should eql 'This is the text of divInPopupOne'
    end
  end
  it "should find the div in secondPopup" do
    @session.within_window("secondPopup") do
      @session.find("//*[@id='divInPopupTwo']").text.should eql 'This is the text of divInPopupTwo'
    end
  end
  it "should find the divs in both popups" do
    @session.within_window("secondPopup") do
      @session.find("//*[@id='divInPopupTwo']").text.should eql 'This is the text of divInPopupTwo'
    end
    @session.within_window("firstPopup") do
      @session.find("//*[@id='divInPopupOne']").text.should eql 'This is the text of divInPopupOne'
    end
  end
  it "should find the div in the main window after finding a div in a popup" do
    @session.within_window("secondPopup") do
      @session.find("//*[@id='divInPopupTwo']").text.should eql 'This is the text of divInPopupTwo'
    end
    @session.find("//*[@id='divInMainWindow']").text.should eql 'This is the text for divInMainWindow'
  end
end
