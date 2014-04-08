Capybara::SpecHelper.spec "touch events", requires: [:touch] do
  before do
    @session.visit('/with_touch')
  end

  it "should single_tap elements" do
    @session.find(:css, '#touchable').single_tap
    expect(@session).to have_text('Tapped')
  end

  it "should double_tap elements" do
    @session.find(:css, '#touchable').double_tap
    expect(@session).to have_text('Double tapped')
  end

  it "should long_press elements" do
    @session.find(:css, '#touchable').long_press
    expect(@session).to have_text('Long pressed')
  end

  it "should flick elements" do
    @session.find(:css, '#touchable').flick(:right)
    expect(@session).to have_text('Flicked')
  end
  
  describe "swipeable" do
    it "should swipe right" do
      @session.find(:css, '#swipeable').swipe(:right)
      expect(@session).to have_text('Swiped right')
    end
    
    it "should swipe down" do
      @session.find(:css, '#swipeable').swipe(down: 300)
      expect(@session).to have_text('Swiped down')
    end
  end
end
