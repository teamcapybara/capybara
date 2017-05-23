# frozen_string_literal: true
Capybara::SpecHelper.spec '#has_css?' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given selector is on the page" do
    expect(@session).to have_css("p")
    expect(@session).to have_css("p a#foo")
  end

  it "should be false if the given selector is not on the page" do
    expect(@session).not_to have_css("abbr")
    expect(@session).not_to have_css("p a#doesnotexist")
    expect(@session).not_to have_css("p.nosuchclass")
  end

  it "should respect scopes" do
    @session.within "//p[@id='first']" do
      expect(@session).to have_css("a#foo")
      expect(@session).not_to have_css("a#red")
    end
  end

  it "should wait for content to appear", requires: [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    expect(@session).to have_css("input[type='submit'][value='New Here']")
  end

  context "with between" do
    it "should be true if the content occurs within the range given" do
      expect(@session).to have_css("p", between: 1..4)
      expect(@session).to have_css("p a#foo", between: 1..3)
      expect(@session).to have_css("p a.doesnotexist", between: 0..8)
    end

    it "should be false if the content occurs more or fewer times than range" do
      expect(@session).not_to have_css("p", between: 6..11 )
      expect(@session).not_to have_css("p a#foo", between: 4..7)
      expect(@session).not_to have_css("p a.doesnotexist", between: 3..8)
    end
  end

  context "with count" do
    it "should be true if the content occurs the given number of times" do
      expect(@session).to have_css("p", count: 3)
      expect(@session).to have_css("p a#foo", count: 1)
      expect(@session).to have_css("p a.doesnotexist", count: 0)
    end

    it "should be false if the content occurs a different number of times than the given" do
      expect(@session).not_to have_css("p", count: 6)
      expect(@session).not_to have_css("p a#foo", count: 2)
      expect(@session).not_to have_css("p a.doesnotexist", count: 1)
    end

    it "should coerce count to an integer" do
      expect(@session).to have_css("p", count: "3")
      expect(@session).to have_css("p a#foo", count: "1")
    end
  end

  context "with maximum" do
    it "should be true when content occurs same or fewer times than given" do
      expect(@session).to have_css("h2.head", maximum: 5) # edge case
      expect(@session).to have_css("h2", maximum: 10)
      expect(@session).to have_css("p a.doesnotexist", maximum: 1)
      expect(@session).to have_css("p a.doesnotexist", maximum: 0)
    end

    it "should be false when content occurs more times than given" do
      expect(@session).not_to have_css("h2.head", maximum: 4) # edge case
      expect(@session).not_to have_css("h2", maximum: 3)
      expect(@session).not_to have_css("p", maximum: 1)
    end

    it "should coerce maximum to an integer" do
      expect(@session).to have_css("h2.head", maximum: "5") # edge case
      expect(@session).to have_css("h2", maximum: "10")
    end
  end

  context "with minimum" do
    it "should be true when content occurs same or more times than given" do
      expect(@session).to have_css("h2.head", minimum: 5) # edge case
      expect(@session).to have_css("h2", minimum: 3)
      expect(@session).to have_css("p a.doesnotexist", minimum: 0)
    end

    it "should be false when content occurs fewer times than given" do
      expect(@session).not_to have_css("h2.head", minimum: 6) # edge case
      expect(@session).not_to have_css("h2", minimum: 8)
      expect(@session).not_to have_css("p", minimum: 10)
      expect(@session).not_to have_css("p a.doesnotexist", minimum: 1)
    end

    it "should coerce minimum to an integer" do
      expect(@session).to have_css("h2.head", minimum: "5") # edge case
      expect(@session).to have_css("h2", minimum: "3")
    end
  end

  context "with text" do
    it "should discard all matches where the given string is not contained" do
      expect(@session).to have_css("p a", text: "Redirect", count: 1)
      expect(@session).not_to have_css("p a", text: "Doesnotexist")
    end

    it "should discard all matches where the given regexp is not matched" do
      expect(@session).to have_css("p a", text: /re[dab]i/i, count: 1)
      expect(@session).not_to have_css("p a", text: /Red$/)
    end
  end

  it "should allow escapes in the CSS selector" do
    if (defined?(TestClass) && @session.is_a?(TestClass)) || @session.driver.is_a?(Capybara::RackTest::Driver)
      # Nokogiri doesn't unescape CSS selectors when converting from CSS to XPath
      # See: https://github.com/teamcapybara/capybara/issues/1866
      # Also: https://github.com/sparklemotion/nokogiri/pull/1646
      pending "Current Nokogiri doesn't handle escapes in CSS attribute selectors correctly"
    end
    expect(@session).to have_css('p[data-random="abc\\\\def"]')
    expect(@session).to have_css("p[data-random='#{Capybara::Selector::CSS.escape('abc\def')}']")
  end
end

Capybara::SpecHelper.spec '#has_no_css?' do
  before do
    @session.visit('/with_html')
  end

  it "should be false if the given selector is on the page" do
    expect(@session).not_to have_no_css("p")
    expect(@session).not_to have_no_css("p a#foo")
  end

  it "should be true if the given selector is not on the page" do
    expect(@session).to have_no_css("abbr")
    expect(@session).to have_no_css("p a#doesnotexist")
    expect(@session).to have_no_css("p.nosuchclass")
  end

  it "should respect scopes" do
    @session.within "//p[@id='first']" do
      expect(@session).not_to have_no_css("a#foo")
      expect(@session).to have_no_css("a#red")
    end
  end

  it "should wait for content to disappear", requires: [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    expect(@session).to have_no_css("p#change")
  end

  context "with between" do
    it "should be false if the content occurs within the range given" do
      expect(@session).not_to have_no_css("p", between: 1..4)
      expect(@session).not_to have_no_css("p a#foo", between: 1..3)
      expect(@session).not_to have_no_css("p a.doesnotexist", between: 0..2)
    end

    it "should be true if the content occurs more or fewer times than range" do
      expect(@session).to have_no_css("p", between: 6..11 )
      expect(@session).to have_no_css("p a#foo", between: 4..7)
      expect(@session).to have_no_css("p a.doesnotexist", between: 3..8)
    end
  end

  context "with count" do
    it "should be false if the content is on the page the given number of times" do
      expect(@session).not_to have_no_css("p", count: 3)
      expect(@session).not_to have_no_css("p a#foo", count: 1)
      expect(@session).not_to have_no_css("p a.doesnotexist", count: 0)
    end

    it "should be true if the content is on the page the given number of times" do
      expect(@session).to have_no_css("p", count: 6)
      expect(@session).to have_no_css("p a#foo", count: 2)
      expect(@session).to have_no_css("p a.doesnotexist", count: 1)
    end

    it "should coerce count to an integer" do
      expect(@session).not_to have_no_css("p", count: "3")
      expect(@session).not_to have_no_css("p a#foo", count: "1")
    end
  end

  context "with maximum" do
    it "should be false when content occurs same or fewer times than given" do
      expect(@session).not_to have_no_css("h2.head", maximum: 5) # edge case
      expect(@session).not_to have_no_css("h2", maximum: 10)
      expect(@session).not_to have_no_css("p a.doesnotexist", maximum: 0)
    end

    it "should be true when content occurs more times than given" do
      expect(@session).to have_no_css("h2.head", maximum: 4) # edge case
      expect(@session).to have_no_css("h2", maximum: 3)
      expect(@session).to have_no_css("p", maximum: 1)
    end

    it "should coerce maximum to an integer" do
      expect(@session).not_to have_no_css("h2.head", maximum: "5") # edge case
      expect(@session).not_to have_no_css("h2", maximum: "10")
    end
  end

  context "with minimum" do
    it "should be false when content occurs same or more times than given" do
      expect(@session).not_to have_no_css("h2.head", minimum: 5) # edge case
      expect(@session).not_to have_no_css("h2", minimum: 3)
      expect(@session).not_to have_no_css("p a.doesnotexist", minimum: 0)
    end

    it "should be true when content occurs fewer times than given" do
      expect(@session).to have_no_css("h2.head", minimum: 6) # edge case
      expect(@session).to have_no_css("h2", minimum: 8)
      expect(@session).to have_no_css("p", minimum: 15)
      expect(@session).to have_no_css("p a.doesnotexist", minimum: 1)
    end

    it "should coerce minimum to an integer" do
      expect(@session).not_to have_no_css("h2.head", minimum: "4") # edge case
      expect(@session).not_to have_no_css("h2", minimum: "3")
    end
  end

  context "with text" do
    it "should discard all matches where the given string is not contained" do
      expect(@session).not_to have_no_css("p a", text: "Redirect", count: 1)
      expect(@session).to have_no_css("p a", text: "Doesnotexist")
    end

    it "should discard all matches where the given regexp is not matched" do
      expect(@session).not_to have_no_css("p a", text: /re[dab]i/i, count: 1)
      expect(@session).to have_no_css("p a", text: /Red$/)
    end
  end
end
