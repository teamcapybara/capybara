Capybara::SpecHelper.spec "#all" do
  before do
    @session.visit('/with_html')
  end

  it "should find all elements using the given locator" do
    @session.all('//p').should have(3).elements
    @session.all('//h1').first.text.should == 'This is a test'
    @session.all("//input[@id='test_field']").first[:value].should == 'monkey'
  end

  it "should return an empty array when nothing was found" do
    @session.all('//div[@id="nosuchthing"]').should be_empty
  end

  it "should accept an XPath instance" do
    @session.visit('/form')
    @xpath = XPath::HTML.fillable_field('Name')
    @result = @session.all(@xpath).map { |r| r.value }
    @result.should include('Smith', 'John', 'John Smith')
  end

  it "should raise an error when given invalid options" do
    expect { @session.all('//p', :schmoo => "foo") }.to raise_error(ArgumentError)
  end

  context "with css selectors" do
    it "should find all elements using the given selector" do
      @session.all(:css, 'h1').first.text.should == 'This is a test'
      @session.all(:css, "input[id='test_field']").first[:value].should == 'monkey'
    end

    it "should find all elements when given a list of selectors" do
      @session.all(:css, 'h1, p').should have(4).elements
    end
  end

  context "with xpath selectors" do
    it "should find the first element using the given locator" do
      @session.all(:xpath, '//h1').first.text.should == 'This is a test'
      @session.all(:xpath, "//input[@id='test_field']").first[:value].should == 'monkey'
    end
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should find the first element using the given locator" do
      @session.all('h1').first.text.should == 'This is a test'
      @session.all("input[id='test_field']").first[:value].should == 'monkey'
    end
  end

  context "with visible filter" do
    it "should only find visible nodes when true" do
      @session.all(:css, "a.simple", :visible => true).should have(1).elements
    end

    it "should find nodes regardless of whether they are invisible when false" do
      @session.all(:css, "a.simple", :visible => false).should have(2).elements
    end

    it "should default to Capybara.ignore_hidden_elements" do
      Capybara.ignore_hidden_elements = true
      @session.all(:css, "a.simple").should have(1).elements
      Capybara.ignore_hidden_elements = false
      @session.all(:css, "a.simple").should have(2).elements
    end
  end

  context 'with element count filters' do
    context ':count' do
      it 'should succeed when the number of elements founds matches the expectation' do
        expect { @session.all(:css, 'h1, p', :count => 4) }.to_not raise_error
      end
      it 'should raise ExpectationNotMet when the number of elements founds does not match the expectation' do
        expect { @session.all(:css, 'h1, p', :count => 5) }.to raise_error(Capybara::ExpectationNotMet)
      end
    end
    context ':minimum' do
      it 'should succeed when the number of elements founds matches the expectation' do
        expect { @session.all(:css, 'h1, p', :minimum => 0) }.to_not raise_error
      end
      it 'should raise ExpectationNotMet when the number of elements founds does not match the expectation' do
        expect { @session.all(:css, 'h1, p', :minimum => 5) }.to raise_error(Capybara::ExpectationNotMet)
      end
    end
    context ':maximum' do
      it 'should succeed when the number of elements founds matches the expectation' do
        expect { @session.all(:css, 'h1, p', :maximum => 4) }.to_not raise_error
      end
      it 'should raise ExpectationNotMet when the number of elements founds does not match the expectation' do
        expect { @session.all(:css, 'h1, p', :maximum => 0) }.to raise_error(Capybara::ExpectationNotMet)
      end
    end
    context ':between' do
      it 'should succeed when the number of elements founds matches the expectation' do
        expect { @session.all(:css, 'h1, p', :between => 2..7) }.to_not raise_error
      end
      it 'should raise ExpectationNotMet when the number of elements founds does not match the expectation' do
        expect { @session.all(:css, 'h1, p', :between => 0..3) }.to raise_error(Capybara::ExpectationNotMet)
      end
    end

    context 'with multiple count filters' do
      it 'ignores other filters when :count is specified' do
        o = {:count   => 4,
             :minimum => 5,
             :maximum => 0,
             :between => 0..3}
        expect { @session.all(:css, 'h1, p', o) }.to_not raise_error
      end
      context 'with no :count expectation' do
        it 'fails if :minimum is not met' do
          o = {:minimum => 5,
               :maximum => 4,
               :between => 2..7}
          expect { @session.all(:css, 'h1, p', o) }.to raise_error(Capybara::ExpectationNotMet)
        end
        it 'fails if :maximum is not met' do
          o = {:minimum => 0,
               :maximum => 0,
               :between => 2..7}
          expect { @session.all(:css, 'h1, p', o) }.to raise_error(Capybara::ExpectationNotMet)
        end
        it 'fails if :between is not met' do
          o = {:minimum => 0,
               :maximum => 4,
               :between => 0..3}
          expect { @session.all(:css, 'h1, p', o) }.to raise_error(Capybara::ExpectationNotMet)
        end
        it 'succeeds if all combineable expectations are met' do
          o = {:minimum => 0,
               :maximum => 4,
               :between => 2..7}
          expect { @session.all(:css, 'h1, p', o) }.to_not raise_error
        end
      end
    end
  end

  context "within a scope" do
    before do
      @session.visit('/with_scope')
    end

    it "should find any element using the given locator" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        @session.all('.//li').should have(2).elements
      end
    end
  end
end
