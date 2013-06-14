Capybara::SpecHelper.spec '#last' do
  before do
    @session.visit('/with_html')
  end

  it "should find the last element using the given locator" do
    @session.last('//h2').text.should == 'Header Class Test Five'
    @session.last("//input[@id='test_field']")[:value].should == 'monkey'
  end

  it "should return nil when nothing was found" do
    @session.last('//div[@id="nosuchthing"]').should be_nil
  end

  it "should accept an XPath instance" do
    @session.visit('/form')
    @xpath = XPath::HTML.fillable_field('First Name')
    @session.last(@xpath).value.should == 'John'
  end

  context "with css selectors" do
    it "should find the last element using the given selector" do
      @session.last(:css, 'h2').text.should == 'Header Class Test Five'
      @session.last(:css, "input[id='test_field']")[:value].should == 'monkey'
    end
  end

  context "with xpath selectors" do
    it "should find the last element using the given locator" do
      @session.last(:xpath, '//h2').text.should == 'Header Class Test Five'
      @session.last(:xpath, "//input[@id='test_field']")[:value].should == 'monkey'
    end
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should find the last element using the given locator" do
      @session.last('h2').text.should == 'Header Class Test Five'
      @session.last("input[id='test_field']")[:value].should == 'monkey'
    end
  end

  context "with visible filter" do
    it "should only find visible nodes when true" do
      @session.last(:css, "a#invisible", :visible => true).should be_nil
    end

    it "should find nodes regardless of whether they are invisible when false" do
      @session.last(:css, "a#invisible", :visible => false).should_not be_nil
      @session.last(:css, "a#visible", :visible => false).should_not be_nil
    end

    it "should find nodes regardless of whether they are invisible when :all" do
      @session.last(:css, "a#invisible", :visible => :all).should_not be_nil
      @session.last(:css, "a#visible", :visible => :all).should_not be_nil
    end

    it "should find only hidden nodes when :hidden" do
      @session.last(:css, "a#invisible", :visible => :hidden).should_not be_nil
      @session.last(:css, "a#visible", :visible => :hidden).should be_nil
    end

    it "should find only visible nodes when :visible" do
      @session.last(:css, "a#invisible", :visible => :visible).should be_nil
      @session.last(:css, "a#visible", :visible => :visible).should_not be_nil
    end

    it "should default to Capybara.ignore_hidden_elements" do
      Capybara.ignore_hidden_elements = true
      @session.last(:css, "a#invisible").should be_nil
      Capybara.ignore_hidden_elements = false
      @session.last(:css, "a#invisible").should_not be_nil
      @session.last(:css, "a").should_not be_nil
    end
  end

  context "within a scope" do
    before do
      @session.visit('/with_scope')
    end

    it "should find the last element using the given locator" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        @session.last('.//form').should_not be_nil
      end
    end
  end
end
