Capybara::SpecHelper.spec '#find' do
  before do
    @session.visit('/with_html')
  end

  after do
    Capybara::Selector.remove(:monkey)
  end

  it "should find the first element using the given locator" do
    @session.find('//h1').text.should == 'This is a test'
    @session.find("//input[@id='test_field']")[:value].should == 'monkey'
  end

  it "should find the first element using the given locator and options" do
    @session.find('//a', :text => 'Redirect')[:id].should == 'red'
    @session.find(:css, 'a', :text => 'A link came first')[:title].should == 'twas a fine link'
  end

  it "should raise an error if there are multiple matches" do
    expect { @session.find('//a') }.to raise_error(Capybara::Ambiguous)
  end

  it "should wait for asynchronous load", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.find(:css, "a#has-been-clicked").text.should include('Has been clicked')
  end

  context "with frozen time", :requires => [:js] do
    it "raises an error suggesting that Capybara is stuck in time" do
      @session.visit('/with_js')
      now = Time.now
      Time.stub(:now).and_return(now)
      expect { @session.find('//isnotthere') }.to raise_error(Capybara::FrozenInTime)
    end
  end

  context "with css selectors" do
    it "should find the first element using the given locator" do
      @session.find(:css, 'h1').text.should == 'This is a test'
      @session.find(:css, "input[id='test_field']")[:value].should == 'monkey'
    end
  end

  context "with xpath selectors" do
    it "should find the first element using the given locator" do
      @session.find(:xpath, '//h1').text.should == 'This is a test'
      @session.find(:xpath, "//input[@id='test_field']")[:value].should == 'monkey'
    end
  end

  context "with custom selector" do
    it "should use the custom selector" do
      Capybara.add_selector(:monkey) do
        xpath { |name| ".//*[@id='#{name}_monkey']" }
      end
      @session.find(:monkey, 'john').text.should == 'Monkey John'
      @session.find(:monkey, 'paul').text.should == 'Monkey Paul'
    end
  end

  context "with custom selector with :for option" do
    it "should use the selector when it matches the :for option" do
      Capybara.add_selector(:monkey) do
        xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
        match { |value| value.is_a?(Fixnum) }
      end
      @session.find(:monkey, '2').text.should == 'Monkey Paul'
      @session.find(1).text.should == 'Monkey John'
      @session.find(2).text.should == 'Monkey Paul'
      @session.find('//h1').text.should == 'This is a test'
    end
  end

  context "with custom selector with custom filter" do
    before do
      Capybara.add_selector(:monkey) do
        xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
        filter(:name) { |node, name| node.text == name }
      end
    end

    it "should find elements that match the filter" do
      @session.find(:monkey, '1', :name => 'Monkey John').text.should == 'Monkey John'
      @session.find(:monkey, '2', :name => 'Monkey Paul').text.should == 'Monkey Paul'
    end

    it "should not find elements that don't match the filter" do
      expect { @session.find(:monkey, '2', :name => 'Monkey John') }.to raise_error(Capybara::ElementNotFound)
      expect { @session.find(:monkey, '1', :name => 'Monkey Paul') }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should find the first element using the given locator" do
      @session.find('h1').text.should == 'This is a test'
      @session.find("input[id='test_field']")[:value].should == 'monkey'
    end
    after { Capybara.default_selector = :xpath }
  end

  it "should raise ElementNotFound with a useful default message if nothing was found" do
    expect do
      @session.find(:xpath, '//div[@id="nosuchthing"]').to be_nil
    end.to raise_error(Capybara::ElementNotFound, "Unable to find xpath \"//div[@id=\\\"nosuchthing\\\"]\"")
  end

  it "should accept an XPath instance" do
    @session.visit('/form')
    @xpath = XPath::HTML.fillable_field('First Name')
    @session.find(@xpath).value.should == 'John'
  end

  context "within a scope" do
    before do
      @session.visit('/with_scope')
    end

    it "should find the an element using the given locator" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        @session.find('.//li[1]').text.should =~ /With Simple HTML/
      end
    end
  end
end
