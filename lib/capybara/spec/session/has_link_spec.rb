Capybara::SpecHelper.spec '#has_link?' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given link is on the page" do
    @session.should have_link('foo')
    @session.should have_link('awesome title')
    @session.should have_link('A link', :href => '/with_simple_html')
    @session.should have_link(:'A link', :href => :'/with_simple_html')
  end

  it "should be false if the given link is not on the page" do
    @session.should_not have_link('monkey')
    @session.should_not have_link('A link', :href => '/non-existant-href')
  end
end

Capybara::SpecHelper.spec '#has_no_link?' do
  before do
    @session.visit('/with_html')
  end

  it "should be false if the given link is on the page" do
    @session.should_not have_no_link('foo')
    @session.should_not have_no_link('awesome title')
    @session.should_not have_no_link('A link', :href => '/with_simple_html')
  end

  it "should be true if the given link is not on the page" do
    @session.should have_no_link('monkey')
    @session.should have_no_link('A link', :href => '/non-existant-href')
  end
end
