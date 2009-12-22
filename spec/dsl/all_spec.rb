module AllSpec
  shared_examples_for "all" do
    describe '#all' do
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
        @xpath = Capybara::XPath.text_field('Name')
        @result = @session.all(@xpath).map { |r| r.value }
        @result.should include('Smith', 'John', 'John Smith')
      end

      context "within a scope" do
        before do
          @session.visit('/with_scope')
        end

        it "should find any element using the given locator" do
          @session.within(:xpath, "//div[@id='for_bar']") do
            @session.all('//li').should have(2).elements
          end
        end
      end
    end
  end
end  