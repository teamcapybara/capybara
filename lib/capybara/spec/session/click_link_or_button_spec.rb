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

  context "with :exact option" do
    context "when `true`" do
      it "clicks on approximately matching link" do
        @session.visit('/with_html')
        @session.click_link_or_button('abore', :exact => false)
        @session.should have_content('Bar')
      end

      it "clicks on approximately matching button" do
        @session.visit('/form')
        @session.click_link_or_button('awe')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "when `false`" do
      it "does not click on link which matches approximately" do
        @session.visit('/with_html')
        msg = "Unable to find link or button \"abore\""
        expect do
          @session.click_link_or_button('abore', :exact => true)
        end.to raise_error(Capybara::ElementNotFound, msg)
      end

      it "does not click on approximately matching button" do
        @session.visit('/form')
        msg = "Unable to find link or button \"awe\""

        expect do
          @session.click_link_or_button('awe', :exact => true)
        end.to raise_error(Capybara::ElementNotFound, msg)
      end
    end
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

  context "with :disabled option" do
    it "ignores disabled buttons when false" do
      @session.visit('/form')
      expect do
        @session.click_link_or_button('Disabled button', :disabled => false)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "ignores disabled buttons by default" do
      @session.visit('/form')
      expect do
        @session.click_link_or_button('Disabled button')
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "happily clicks on links which incorrectly have the disabled attribute" do
      @session.visit('/with_html')
      @session.click_link_or_button('Disabled link')
      @session.should have_content("Bar")
    end

    it "does nothing when button is disabled" do
      @session.visit('/form')
      expect do
        @session.click_link_or_button('Disabled button', :disabled => false)
      end.to raise_error(Capybara::ElementNotFound)
    end

  end
end
