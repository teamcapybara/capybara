Capybara::SpecHelper.spec '#has_title?' do
  before do
    @session.visit('/with_js')
  end

  it "should be true if the page has the given title" do
    @session.should have_title('with_js')
  end

  it "should allow regexp matches" do
    @session.should have_title(/w[a-z]{3}_js/)
    @session.should_not have_title(/monkey/)
  end

  it "should wait for title", :requires => [:js] do
    @session.click_link("Change title")
    @session.should have_title("changed title")
  end

  it "should be false if the page has not the given title" do
    @session.should_not have_title('monkey')
  end
end

Capybara::SpecHelper.spec '#has_no_title?' do
  before do
    @session.visit('/with_js')
  end

  it "should be false if the page has the given title" do
    @session.should_not have_no_title('with_js')
  end

  it "should allow regexp matches" do
    @session.should_not have_no_title(/w[a-z]{3}_js/)
    @session.should have_no_title(/monkey/)
  end

  it "should wait for title to disappear", :requires => [:js] do
    @session.click_link("Change title")
    @session.should have_no_title('with_js')
  end

  it "should be true if the page has not the given title" do
    @session.should have_no_title('monkey')
  end
end
