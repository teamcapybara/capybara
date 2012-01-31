shared_examples_for "unselect" do
  describe "#unselect" do
    before do
      @session.visit('/form')
    end

    context "with multiple select" do
      it "should unselect an option from a select box by id" do
        @session.unselect('Commando', :from => 'form_underwear')
        @session.click_button('awesome')
        extract_results(@session)['underwear'].should include('Briefs', 'Boxerbriefs')
        extract_results(@session)['underwear'].should_not include('Commando')
      end

      it "should unselect an option without a select box" do
        @session.unselect('Commando')
        @session.click_button('awesome')
        extract_results(@session)['underwear'].should include('Briefs', 'Boxerbriefs')
        extract_results(@session)['underwear'].should_not include('Commando')
      end

      it "should unselect an option from a select box by label" do
        @session.unselect('Commando', :from => 'Underwear')
        @session.click_button('awesome')
        extract_results(@session)['underwear'].should include('Briefs', 'Boxerbriefs')
        extract_results(@session)['underwear'].should_not include('Commando')
      end

      it "should favour exact matches to option labels" do
        @session.unselect("Briefs", :from => 'Underwear')
        @session.click_button('awesome')
        extract_results(@session)['underwear'].should include('Commando', 'Boxerbriefs')
        extract_results(@session)['underwear'].should_not include('Briefs')
      end

      it "should escape quotes" do
        @session.unselect("Frenchman's Pantalons", :from => 'Underwear')
        @session.click_button('awesome')
        extract_results(@session)['underwear'].should_not include("Frenchman's Pantalons")
      end
    end

    context "with single select" do
      it "should raise an error" do
        running { @session.unselect("English", :from => 'form_locale') }.should raise_error(Capybara::UnselectNotAllowed)
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        msg = "no select box with id, name, or label 'does not exist' found"
        running do
          @session.unselect('foo', :from => 'does not exist')
        end.should raise_error(Capybara::ElementNotFound, msg)
      end
    end

    context "with an option that doesn't exist" do
      it "should raise an error" do
        msg = "no option with text 'Does not Exist' in the select box"
        running do
          @session.unselect('Does not Exist', :from => 'form_underwear')
        end.should raise_error(Capybara::ElementNotFound, msg)
      end
    end
  end
end
