Capybara::SpecHelper.spec '#has_link_to?' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given link is on the page" do
    @session.should have_link_to('/foo')
    @session.should have_link_to('/with_simple_html')
    @session.should have_link_to('/redirect')
  end

  it "should be false if the given link is not on the page" do
    @session.should_not have_link_to('/monkey')
    @session.should_not have_link_to('/non-existant-href')
  end
end

Capybara::SpecHelper.spec '#has_no_link_to?' do
  before do
    @session.visit('/with_html')
  end

  it "should be false if the given link is on the page" do
    @session.should_not have_no_link_to('/foo')
    @session.should_not have_no_link_to('/with_simple_html')
    @session.should_not have_no_link_to('/redirect')
  end

  it "should be true if the given link is not on the page" do
    @session.should have_no_link_to('/monkey')
    @session.should have_no_link_to('/non-existant-href')
  end
end
