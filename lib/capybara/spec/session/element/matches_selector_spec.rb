Capybara::SpecHelper.spec '#match_xpath?' do
  before do
    @session.visit('/with_html')
    @element = @session.find('//span', text: '42')
  end

  it "should be true if the element matches the given selector" do
    expect(@element).to match_selector(:xpath, "//span")
    expect(@element).to match_selector(:css, 'span.number')
    expect(@element.matches_selector?(:css, 'span.number')).to be true
  end

  it "should be false if the element does not match the given selector" do
    expect(@element).not_to match_selector(:xpath, "//div")
    expect(@element).not_to match_selector(:css, "span.not_a_number")
    expect(@element.matches_selector?(:css, "span.not_a_number")).to be false
  end

  it "should use default selector" do
    Capybara.default_selector = :css
    expect(@element).not_to match_selector("span.not_a_number")
    expect(@element).to match_selector("span.number")
  end

  context "with text" do
    it "should discard all matches where the given string is not contained" do
      expect(@element).to match_selector("//span", :text => "42")
      expect(@element).not_to match_selector("//span", :text => "Doesnotexist")
    end
  end
end

Capybara::SpecHelper.spec '#not_matches_selector?' do
  before do
    @session.visit('/with_html')
    @element = @session.find(:css, "span", text: 42)
  end

  it "should be false if the given selector matches the element" do
    expect(@element).not_to not_match_selector(:xpath, "//span")
    expect(@element).not_to not_match_selector(:css, "span.number")
    expect(@element.not_matches_selector?(:css, "span.number")).to be false
  end

  it "should be true if the given selector does not match the element" do
    expect(@element).to not_match_selector(:xpath, "//abbr")
    expect(@element).to not_match_selector(:css, "p a#doesnotexist")
    expect(@element.not_matches_selector?(:css, "p a#doesnotexist")).to be true
  end

  it "should use default selector" do
    Capybara.default_selector = :css
    expect(@element).to not_match_selector("p a#doesnotexist")
    expect(@element).not_to not_match_selector("span.number")
  end

  context "with text" do
    it "should discard all matches where the given string is contained" do
      expect(@element).not_to not_match_selector(:css, "span.number", :text => "42")
      expect(@element).to not_match_selector(:css, "span.number", :text => "Doesnotexist")
    end
  end
end if Gem::Version.new(RSpec::Expectations::Version::STRING) >= Gem::Version.new('3.1')
