shared_examples_for "click_link_or_button" do
  describe '#click' do
    it "should click on a link" do
      @session.visit('/with_html')
      @session.click_link_or_button('labore')
      @session.body.should include('Bar')
    end

    it "should click on a button" do
      @session.visit('/form')
      @session.click_link_or_button('awe123')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should click on a button with no type attribute" do
      @session.visit('/form')
      @session.click_link_or_button('no_type')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should be aliased as click_on" do
      @session.visit('/form')
      @session.click_on('awe123')
      extract_results(@session)['first_name'].should == 'John'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        @session.visit('/with_html')
        running do
          @session.click_link_or_button('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
