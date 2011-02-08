shared_examples_for "first" do
  describe '#first' do
    before do
      @session.visit('/with_html')
    end

    it "should find the first element using the given locator" do
      @session.first('//h1').text.should == 'This is a test'
      @session.first("//input[@id='test_field']")[:value].should == 'monkey'
    end

    it "should return nil when nothing was found" do
      @session.first('//div[@id="nosuchthing"]').should be_nil
    end

    it "should accept an XPath instance" do
      @session.visit('/form')
      @xpath = XPath::HTML.fillable_field('Name')
      @session.first(@xpath).value.should == 'John Smith'
    end

    context "with css selectors" do
      it "should find the first element using the given selector" do
        @session.first(:css, 'h1').text.should == 'This is a test'
        @session.first(:css, "input[id='test_field']")[:value].should == 'monkey'
      end
    end

    context "with xpath selectors" do
      it "should find the first element using the given locator" do
        @session.first(:xpath, '//h1').text.should == 'This is a test'
        @session.first(:xpath, "//input[@id='test_field']")[:value].should == 'monkey'
      end
    end

    context "with css as default selector" do
      before { Capybara.default_selector = :css }
      it "should find the first element using the given locator" do
        @session.first('h1').text.should == 'This is a test'
        @session.first("input[id='test_field']")[:value].should == 'monkey'
      end
      after { Capybara.default_selector = :xpath }
    end

    context "with visible filter" do
      after { Capybara.ignore_hidden_elements = false }
      it "should only find visible nodes if true given" do
        @session.first(:css, "a#invisible").should_not be_nil
        @session.first(:css, "a#invisible", :visible => true).should be_nil
        Capybara.ignore_hidden_elements = true
        @session.first(:css, "a#invisible").should be_nil
      end

      it "should include invisible nodes if false given" do
        Capybara.ignore_hidden_elements = true
        @session.first(:css, "a#invisible", :visible => false).should_not be_nil
        @session.first(:css, "a#invisible").should be_nil
      end
    end

    context "with prefer visible elements" do
      it "should find invisible elements if no visible element exists" do
        @session.first(:css, 'a#invisible')[:id].should == 'invisible'
      end

      it "should prefer visible elements over invisible elements" do
        @session.first(:css, 'a.visibility')[:id].should == 'visible'
      end

      it "should return the first invisible element if no visible elements exist" do
        @session.first(:css, 'a.hidden')[:id].should == 'first_invisble'
      end

      it "find visible links normally" do
        @session.first(:css, 'a#visible')[:id].should == 'visible'
      end
    end

    context "without prefer visible elements" do
      before { Capybara.prefer_visible_elements = false }

      it "should find invisible elements if no visible element exists" do
        @session.first(:css, 'a#invisible')[:id].should == 'invisible'
      end

      it "should not prefer visible elements over invisible elements" do
        @session.first(:css, 'a.visibility')[:id].should == 'invisible'
      end

      after { Capybara.prefer_visible_elements = true }
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find the first element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.first('.//form').should_not be_nil
        end
      end
    end
  end
end
