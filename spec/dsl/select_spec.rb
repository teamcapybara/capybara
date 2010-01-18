shared_examples_for "select" do
  describe "#select" do
    before do
      @session.visit('/form')
    end

    it "should select an option from a select box by id" do
      @session.select("Finish", :from => 'form_locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    it "should select an option from a select box by label" do
      @session.select("Finish", :from => 'Locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.select('foo', :from => 'does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
