Capybara::SpecHelper.spec '#click_link_or_button' do
  it "should click on a link" do
    @session.visit('/with_html')
    @session.click_link_or_button('labore')
    @session.should have_content('Bar')
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

  it "should wait for asynchronous load", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.click_link_or_button('Has been clicked')
  end

  it "casts to string" do
    @session.visit('/form')
    @session.click_link_or_button(:'awe123')
    extract_results(@session)['first_name'].should == 'John'
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      @session.visit('/with_html')
      msg = "Unable to find link or button \"does not exist\""
      expect do
        @session.click_link_or_button('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end
end
