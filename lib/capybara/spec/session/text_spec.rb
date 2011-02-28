shared_examples_for "text" do
  describe '#text' do
    before do
      @session.visit('/with_simple_html')
    end

    it "should print the text of the page" do
      @session.text.should == 'Bar'
    end

    context "with css as default selector" do
      before { Capybara.default_selector = :css }
      it "should print the text of the page" do
        @session.text.should == 'Bar'
      end
      after { Capybara.default_selector = :xpath }
    end
  end
end
