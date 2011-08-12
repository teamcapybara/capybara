shared_examples_for "find" do
  describe '#find' do
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
      @session.find(:css, 'a', :text => 'A link')[:title].should == 'twas a fine link'
    end

    describe 'the returned node' do
      it "should act like a session object" do
        @session.visit('/form')
        @form = @session.find(:css, '#get-form')
        @form.should have_field('Middle Name')
        @form.should have_no_field('Languages')
        @form.fill_in('Middle Name', :with => 'Monkey')
        @form.click_button('med')
        extract_results(@session)['middle_name'].should == 'Monkey'
      end

      it "should scope CSS selectors" do
        @session.find(:css, '#second').should have_no_css('h1')
      end

      it "should have a reference to its parent if there is one" do
        @node = @session.find(:css, '#first')
        @node.parent.should == @node.session.document
        @node.find('a').parent.should == @node
      end
    end

    context "with css selectors" do
      it "should find the first element using the given locator" do
        @session.find(:css, 'h1').text.should == 'This is a test'
        @session.find(:css, "input[id='test_field']")[:value].should == 'monkey'
      end
    end

    context "with id selectors" do
      it "should find the first element using the given locator" do
        @session.find(:id, 'john_monkey').text.should == 'Monkey John'
        @session.find(:id, 'red').text.should == 'Redirect'
        @session.find(:red).text.should == 'Redirect'
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

    context "with custom selector with failure_message option" do
      it "should raise an error with the failure message if the element is not found" do
        Capybara.add_selector(:monkey) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          failure_message { |node, selector| node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
        end
        running do
          @session.find(:monkey, '14').text.should == 'Monkey Paul'
        end.should raise_error(Capybara::ElementNotFound, "Monkey John, Monkey Paul")
      end

      it "should pass the selector as the second argument" do
        Capybara.add_selector(:monkey) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          failure_message { |node, selector| selector.name.to_s + ': ' + selector.locator + ' - ' + node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
        end
        running do
          @session.find(:monkey, '14').text.should == 'Monkey Paul'
        end.should raise_error(Capybara::ElementNotFound, "monkey: 14 - Monkey John, Monkey Paul")
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

    it "should raise ElementNotFound with specified fail message if nothing was found" do
      running do
        @session.find(:xpath, '//div[@id="nosuchthing"]', :message => 'arghh').should be_nil
      end.should raise_error(Capybara::ElementNotFound, "arghh")
    end

    it "should raise ElementNotFound with a useful default message if nothing was found" do
      running do
        @session.find(:xpath, '//div[@id="nosuchthing"]').should be_nil
      end.should raise_error(Capybara::ElementNotFound, "Unable to find xpath \"//div[@id=\\\"nosuchthing\\\"]\"")
    end

    it "should accept an XPath instance and respect the order of paths" do
      @session.visit('/form')
      @xpath = XPath::HTML.fillable_field('Name')
      @session.find(@xpath).value.should == 'John Smith'
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find the first element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.find('.//li').text.should =~ /With Simple HTML/
        end
      end
    end
  end
end
