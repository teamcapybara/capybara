# frozen_string_literal: true
Capybara::SpecHelper.spec '#has_selector?' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given selector is on the page" do
    expect(@session).to have_selector(:xpath, "//p")
    expect(@session).to have_selector(:css, "p a#foo")
    expect(@session).to have_selector("//p[contains(.,'est')]")
  end

  it "should be false if the given selector is not on the page" do
    expect(@session).not_to have_selector(:xpath, "//abbr")
    expect(@session).not_to have_selector(:css, "p a#doesnotexist")
    expect(@session).not_to have_selector("//p[contains(.,'thisstringisnotonpage')]")
  end

  it "should use default selector" do
    Capybara.default_selector = :css
    expect(@session).not_to have_selector("p a#doesnotexist")
    expect(@session).to have_selector("p a#foo")
  end

  it "should respect scopes" do
    @session.within "//p[@id='first']" do
      expect(@session).to have_selector(".//a[@id='foo']")
      expect(@session).not_to have_selector(".//a[@id='red']")
    end
  end

  context "with count" do
    it "should be true if the content is on the page the given number of times" do
      expect(@session).to have_selector("//p", :count => 3)
      expect(@session).to have_selector("//p//a[@id='foo']", :count => 1)
      expect(@session).to have_selector("//p[contains(.,'est')]", :count => 1)
    end

    it "should be false if the content is on the page the given number of times" do
      expect(@session).not_to have_selector("//p", :count => 6)
      expect(@session).not_to have_selector("//p//a[@id='foo']", :count => 2)
      expect(@session).not_to have_selector("//p[contains(.,'est')]", :count => 5)
    end

    it "should be false if the content isn't on the page at all" do
      expect(@session).not_to have_selector("//abbr", :count => 2)
      expect(@session).not_to have_selector("//p//a[@id='doesnotexist']", :count => 1)
    end
  end

  context "with text" do
    it "should discard all matches where the given string is not contained" do
      expect(@session).to have_selector("//p//a", :text => "Redirect", :count => 1)
      expect(@session).not_to have_selector("//p", :text => "Doesnotexist")
    end

    it "should respect visibility setting" do
      expect(@session).to have_selector(:id, "hidden-text", :text => "Some of this text is hidden!", :visible => false)
      expect(@session).not_to have_selector(:id, "hidden-text", :text => "Some of this text is hidden!", :visible => true)
      Capybara.ignore_hidden_elements = false
      expect(@session).to have_selector(:id, "hidden-text", :text => "Some of this text is hidden!", :visible => false)
      Capybara.visible_text_only = true
      expect(@session).not_to have_selector(:id, "hidden-text", :text => "Some of this text is hidden!", :visible => true)
    end

    it "should discard all matches where the given regexp is not matched" do
      expect(@session).to have_selector("//p//a", :text => /re[dab]i/i, :count => 1)
      expect(@session).not_to have_selector("//p//a", :text => /Red$/)
    end

    it "should warn when extra parameters passed" do
      expect_any_instance_of(Kernel).to receive(:warn).with(/extra/)
      expect(@session).to have_selector(:css, "p a#foo", 'extra')
    end
  end
end

Capybara::SpecHelper.spec '#has_no_selector?' do
  before do
    @session.visit('/with_html')
  end

  it "should be false if the given selector is on the page" do
    expect(@session).not_to have_no_selector(:xpath, "//p")
    expect(@session).not_to have_no_selector(:css, "p a#foo")
    expect(@session).not_to have_no_selector("//p[contains(.,'est')]")
  end

  it "should be true if the given selector is not on the page" do
    expect(@session).to have_no_selector(:xpath, "//abbr")
    expect(@session).to have_no_selector(:css, "p a#doesnotexist")
    expect(@session).to have_no_selector("//p[contains(.,'thisstringisnotonpage')]")
  end

  it "should use default selector" do
    Capybara.default_selector = :css
    expect(@session).to have_no_selector("p a#doesnotexist")
    expect(@session).not_to have_no_selector("p a#foo")
  end

  it "should respect scopes" do
    @session.within "//p[@id='first']" do
      expect(@session).not_to have_no_selector(".//a[@id='foo']")
      expect(@session).to have_no_selector(".//a[@id='red']")
    end
  end

  context "with count" do
    it "should be false if the content is on the page the given number of times" do
      expect(@session).not_to have_no_selector("//p", :count => 3)
      expect(@session).not_to have_no_selector("//p//a[@id='foo']", :count => 1)
      expect(@session).not_to have_no_selector("//p[contains(.,'est')]", :count => 1)
    end

    it "should be true if the content is on the page the wrong number of times" do
      expect(@session).to have_no_selector("//p", :count => 6)
      expect(@session).to have_no_selector("//p//a[@id='foo']", :count => 2)
      expect(@session).to have_no_selector("//p[contains(.,'est')]", :count => 5)
    end

    it "should be true if the content isn't on the page at all" do
      expect(@session).to have_no_selector("//abbr", :count => 2)
      expect(@session).to have_no_selector("//p//a[@id='doesnotexist']", :count => 1)
    end
  end

  context "with text" do
    it "should discard all matches where the given string is contained" do
      expect(@session).not_to have_no_selector("//p//a", :text => "Redirect", :count => 1)
      expect(@session).to have_no_selector("//p", :text => "Doesnotexist")
    end

    it "should discard all matches where the given regexp is matched" do
      expect(@session).not_to have_no_selector("//p//a", :text => /re[dab]i/i, :count => 1)
      expect(@session).to have_no_selector("//p//a", :text => /Red$/)
    end
  end
end
