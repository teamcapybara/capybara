Capybara::SpecHelper.spec '#match_css?' do
  before do
    @session.visit('/with_html')
    @element = @session.find(:css, 'span', text: '42')
  end

  it "should be true if the given selector matches the element" do
    expect(@element).to match_css("span")
    expect(@element).to match_css("span.number")
  end

  it "should be false if the given selector does not match" do
    expect(@element).not_to match_css("div")
    expect(@element).not_to match_css("p a#doesnotexist")
    expect(@element).not_to match_css("p.nosuchclass")
  end
end
