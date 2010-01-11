module UncheckSpec
  shared_examples_for "uncheck" do  
    describe "#uncheck" do
      before do
        @session.visit('/form')
      end

      it "should uncheck a checkbox by id" do
        @session.uncheck("form_pets_hamster")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog')
        extract_results(@session)['pets'].should_not include('hamster')
      end

      it "should uncheck a checkbox by label" do
        @session.uncheck("Hamster")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog')
        extract_results(@session)['pets'].should_not include('hamster')
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running { @session.uncheck('does not exist') }.should raise_error(Capybara::ElementNotFound)
        end
      end

      context "with a locator that selects a hidden node" do
        before do
          Capybara.ignore_hidden_elements = false
        end

        after do
          Capybara.ignore_hidden_elements = true
        end

        it "should raise an error" do
          running do
            @session.uncheck('hidden_checked_checkbox')
          end.should raise_error(Capybara::LocateHiddenElementError)
        end
      end
    end
  end
end  
