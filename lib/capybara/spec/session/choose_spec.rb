Capybara::SpecHelper.spec "#choose" do
  before do
    @session.visit('/form')
  end

  it "should choose a radio button by id" do
    @session.choose("gender_male")
    @session.click_button('awesome')
    extract_results(@session)['gender'].should == 'male'
  end

  it "should choose a radio button by label" do
    @session.choose("Both")
    @session.click_button('awesome')
    extract_results(@session)['gender'].should == 'both'
  end

  it "casts to string" do
    @session.choose("Both")
    @session.click_button(:'awesome')
    extract_results(@session)['gender'].should == 'both'
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find radio button \"does not exist\""
      running do
        @session.choose('does not exist')
      end.should raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a disabled radio button" do
    it "should raise an error" do
      running do
        @session.choose('Disabled Radio')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
