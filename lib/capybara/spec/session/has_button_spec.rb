Capybara::SpecHelper.spec '#has_button?' do
  before do
    @session.visit('/form')
  end

  it "should be true if the given button is on the page" do
    @session.should have_button('med')
    @session.should have_button('crap321')
    @session.should have_button(:'crap321')
  end

  it "should be true for disabled buttons if :disabled => true" do
    @session.should have_button('Disabled button', :disabled => true)
  end

  it "should be false if the given button is not on the page" do
    @session.should_not have_button('monkey')
  end

  it "should be false for disabled buttons by default" do
    @session.should_not have_button('Disabled button')
  end

  it "should be false for disabled buttons if :disabled => false" do
    @session.should_not have_button('Disabled button', :disabled => false)
  end
end

Capybara::SpecHelper.spec '#has_no_button?' do
  before do
    @session.visit('/form')
  end

  it "should be true if the given button is on the page" do
    @session.should_not have_no_button('med')
    @session.should_not have_no_button('crap321')
  end

  it "should be true for disabled buttons if :disabled => true" do
    @session.should_not have_no_button('Disabled button', :disabled => true)
  end

  it "should be false if the given button is not on the page" do
    @session.should have_no_button('monkey')
  end

  it "should be false for disabled buttons by default" do
    @session.should have_no_button('Disabled button')
  end

  it "should be false for disabled buttons if :disabled => false" do
    @session.should have_no_button('Disabled button', :disabled => false)
  end
end
