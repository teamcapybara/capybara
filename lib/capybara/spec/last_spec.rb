# frozen_string_literal: true
Capybara::SpecHelper.spec '#last' do
  before do
    @session.visit('/with_html')
  end

  it "should find the last element using the given locator" do
    expect(@session.last('//h2').text).to eq('Header Class Test Five')
    expect(@session.last("//input[@id='test_field']")[:value]).to eq('monkey')
  end

  it "should return nil when nothing was found" do
    expect(@session.last('//div[@id="nosuchthing"]')).to be_nil
  end

  it "should accept an XPath instance" do
    @session.visit('/form')
    @xpath = XPath::HTML.fillable_field('First Name')
    expect(@session.last(@xpath).value).to eq('John')
  end

  context "with css selectors" do
    it "should find the last element using the given selector" do
      expect(@session.last(:css, 'h1').text).to eq('This is a test')
      expect(@session.last(:css, "input[id='test_field']")[:value]).to eq('monkey')
    end
  end

  context "with xpath selectors" do
    it "should find the last element using the given locator" do
      expect(@session.last(:xpath, '//h1').text).to eq('This is a test')
      expect(@session.last(:xpath, "//input[@id='test_field']")[:value]).to eq('monkey')
    end
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should find the last element using the given locator" do
      expect(@session.last('h1').text).to eq('This is a test')
      expect(@session.last("input[id='test_field']")[:value]).to eq('monkey')
    end
  end

  context "with visible filter" do
    it "should only find visible nodes when true" do
      expect(@session.last(:css, "a#invisible", :visible => true)).to be_nil
    end

    it "should find nodes regardless of whether they are invisible when false" do
      expect(@session.last(:css, "a#invisible", :visible => false)).not_to be_nil
      expect(@session.last(:css, "a#visible", :visible => false)).not_to be_nil
    end

    it "should find nodes regardless of whether they are invisible when :all" do
      expect(@session.last(:css, "a#invisible", :visible => :all)).not_to be_nil
      expect(@session.last(:css, "a#visible", :visible => :all)).not_to be_nil
    end

    it "should find only hidden nodes when :hidden" do
      expect(@session.last(:css, "a#invisible", :visible => :hidden)).not_to be_nil
      expect(@session.last(:css, "a#visible", :visible => :hidden)).to be_nil
    end

    it "should find only visible nodes when :visible" do
      expect(@session.last(:css, "a#invisible", :visible => :visible)).to be_nil
      expect(@session.last(:css, "a#visible", :visible => :visible)).not_to be_nil
    end

    it "should default to Capybara.ignore_hidden_elements" do
      Capybara.ignore_hidden_elements = true
      expect(@session.last(:css, "a#invisible")).to be_nil
      Capybara.ignore_hidden_elements = false
      expect(@session.last(:css, "a#invisible")).not_to be_nil
      expect(@session.last(:css, "a")).not_to be_nil
    end
  end

  context "within a scope" do
    before do
      @session.visit('/with_scope')
    end

    it "should find the last element using the given locator" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        expect(@session.last('.//form')).not_to be_nil
      end
    end
  end

  context "with Capybara.wait_on_first_by_default", requires: [:js] do
    before do
      @session.visit('/with_js')
    end

    it "should not wait if false" do
      Capybara.wait_on_first_by_default = false
      @session.click_link('clickable')
      expect(@session.last(:css, 'a#has-been-clicked')).to be_nil
    end

    it "should wait for at least one match if true" do
      Capybara.wait_on_first_by_default = true
      @session.click_link('clickable')
      expect(@session.last(:css, 'a#has-been-clicked')).not_to be_nil
    end

    it "should return nil after waiting if no match" do
      Capybara.wait_on_first_by_default = true
      @session.click_link('clickable')
      expect(@session.last(:css, 'a#not-a-real-link')).to be_nil
    end
  end
end
