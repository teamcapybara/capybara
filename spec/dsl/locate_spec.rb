module LocateSpec
  shared_examples_for "locate" do
    describe '#locate' do
      before do
        @session.visit('/with_html')
      end

      it "should find the first element using the given locator" do
        @session.locate('//h1').text.should == 'This is a test'
        @session.locate("//input[@id='test_field']")[:value].should == 'monkey'
      end

      it "should raise ElementNotFound with specified fail message if nothing was found" do
        running do
          @session.locate('//div[@id="nosuchthing"]', 'arghh').should be_nil
        end.should raise_error(Capybara::ElementNotFound, "arghh")
      end

      it "should accept an XPath instance and respect the order of paths" do
        @session.visit('/form')
        @xpath = Capybara::XPath.text_field('Name')
        @session.locate(@xpath).value.should == 'John Smith'
      end

      it "should return a visible node by default" do
        @session.visit('/form')
        @session.locate(Capybara::XPath.text_field('First Name')).should be_visible
      end

      context "when ignore_hidden_elements is false" do
        before do
          Capybara.ignore_hidden_elements = false
          @session.visit('/form')
          @xpath = Capybara::XPath.text_field('First Name')
        end

        after do
          Capybara.ignore_hidden_elements = true
        end

        it "should not raise an exception hitting a hidden element" do
          running { @session.locate(@xpath) }
        end

        it "should locate hidden elements" do
          element = @session.locate(@xpath)
          element.value.should == 'John'
          element.should_not be_visible
        end

      end

      context "within a scope" do
        before do
          @session.visit('/with_scope')
        end

        it "should find the first element using the given locator" do
          @session.within(:xpath, "//div[@id='for_bar']") do
            @session.locate('//li').text.should =~ /With Simple HTML/
          end        
        end
      end
    end
  end
end  
