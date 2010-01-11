module CheckSpec
  shared_examples_for "check" do
  
    describe "#check" do
      before do
        @session.visit('/form')
      end

      it "should check a checkbox by id" do
        @session.check("form_pets_cat")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
      end

      it "should check a checkbox by label" do
        @session.check("Cat")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running { @session.check('does not exist') }.should raise_error(Capybara::ElementNotFound)
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
            @session.check('hidden_unchecked_checkbox')
          end.should raise_error(Capybara::LocateHiddenElementError)
        end
      end
    end
  end
end  
