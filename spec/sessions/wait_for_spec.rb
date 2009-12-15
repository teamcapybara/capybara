module WaitForSpec
  shared_examples_for "wait_for" do
    describe '#wait_for' do
      before do
        @session.visit('/with_html')
      end

      it "should find the first element using the given locator" do
        @session.wait_for('//h1').text.should == 'This is a test'
        @session.wait_for("//input[@id='test_field']")[:value].should == 'monkey'
      end

      it "should return nil when nothing was found" do
        @session.wait_for('//div').should be_nil
      end

      it "should accept an XPath instance and respect the order of paths" do
        @session.visit('/form')
        @xpath = Capybara::XPath.text_field('Name')
        @session.wait_for(@xpath).value.should == 'John Smith'
      end

      context "within a scope" do
        before do
          @session.visit('/with_scope')
        end

        it "should find the first element using the given locator" do
          @session.within(:xpath, "//div[@id='for_bar']") do
            @session.wait_for('//li').text.should =~ /With Simple HTML/
          end        
        end
      end
    end
  end
end  