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
    
    it "should support pseudo selectors" do
      @session.find(:css, 'input:disabled').value.should == 'This is disabled'
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

  context "with :exact option" do
    it "matches exactly when true" do
      @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("test_field")], :exact => true).value.should == "monkey"
      expect do
        @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")], :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "matches loosely when false" do
      @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("test_field")], :exact => false).value.should == "monkey"
      @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")], :exact => false).value.should == "monkey"
    end

    it "defaults to `Capybara.exact`" do
      Capybara.exact = true
      expect do
        @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")])
      end.to raise_error(Capybara::ElementNotFound)
      Capybara.exact = false
      @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")])
    end
  end

  context "with :match option" do
    context "when set to `one`" do
      it "raises an error when multiple matches exist" do
        expect do
          @session.find(:css, ".multiple", :match => :one)
        end.to raise_error(Capybara::Ambiguous)
      end
      it "raises an error even if there the match is exact and the others are inexact" do
        expect do
          @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], :exact => false, :match => :one)
        end.to raise_error(Capybara::Ambiguous)
      end
      it "returns the element if there is only one" do
        @session.find(:css, ".singular", :match => :one).text.should == "singular"
      end
      it "raises an error if there is no match" do
        expect do
          @session.find(:css, ".does-not-exist", :match => :any)
        end.to raise_error(Capybara::ElementNotFound)
      end
    end

    context "when set to `any`" do
      it "returns the first matched element" do
        @session.find(:css, ".multiple", :match => :any).text.should == "multiple one"
      end
      it "raises an error if there is no match" do
        expect do
          @session.find(:css, ".does-not-exist", :match => :any)
        end.to raise_error(Capybara::ElementNotFound)
      end
    end

    context "when set to `smart`" do
      context "and `exact` set to `false`" do
        it "raises an error when there are multiple exact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], :match => :smart, :exact => false)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], :match => :smart, :exact => false)
          result.text.should == "almost singular"
        end
        it "raises an error when there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], :match => :smart, :exact => false)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single inexact match" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], :match => :smart, :exact => false)
          result.text.should == "almost singular but not quite"
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:css, ".does-not-exist", :match => :smart, :exact => false)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end

      context "with `exact` set to `true`" do
        it "raises an error when there are multiple exact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], :match => :smart, :exact => true)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], :match => :smart, :exact => true)
          result.text.should == "almost singular"
        end
        it "raises an error when there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], :match => :smart, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error when there is a single inexact matches" do
          expect do
            result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], :match => :smart, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:css, ".does-not-exist", :match => :smart, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end
    end

    context "when set to `prefer_exact`" do
      context "and `exact` set to `false`" do
        it "picks the first one when there are multiple exact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], :match => :prefer_exact, :exact => false)
          result.text.should == "multiple one"
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], :match => :prefer_exact, :exact => false)
          result.text.should == "almost singular"
        end
        it "picks the first one when there are multiple inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], :match => :prefer_exact, :exact => false)
          result.text.should == "almost singular but not quite"
        end
        it "finds a single inexact match" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], :match => :prefer_exact, :exact => false)
          result.text.should == "almost singular but not quite"
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:css, ".does-not-exist", :match => :prefer_exact, :exact => false)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end

      context "with `exact` set to `true`" do
        it "picks the first one when there are multiple exact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], :match => :prefer_exact, :exact => true)
          result.text.should == "multiple one"
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], :match => :prefer_exact, :exact => true)
          result.text.should == "almost singular"
        end
        it "raises an error if there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], :match => :prefer_exact, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is a single inexact match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], :match => :prefer_exact, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:css, ".does-not-exist", :match => :prefer_exact, :exact => true)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end
    end

    it "defaults to `Capybara.match`" do
      Capybara.match = :one
      expect do
        @session.find(:css, ".multiple")
      end.to raise_error(Capybara::Ambiguous)
      Capybara.match = :any
      @session.find(:css, ".multiple").text.should == "multiple one"
    end
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
    
    it "should support pseudo selectors" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        @session.find(:css, 'input:disabled').value.should == 'James'
      end
    end
  end
end
