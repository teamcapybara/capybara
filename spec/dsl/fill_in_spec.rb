module FillInSpec
  shared_examples_for "fill_in" do
    describe "#fill_in" do
      before do
        @session.visit('/form')
      end

      it "should fill in a text field by id" do
        @session.fill_in('form_first_name', :with => 'Harry')
        @session.click_button('awesome')
        extract_results(@session)['first_name'].should == 'Harry'
      end

      it "should fill in a text field by label" do
        @session.fill_in('First Name', :with => 'Harry')
        @session.click_button('awesome')
        extract_results(@session)['first_name'].should == 'Harry'
      end

      it "should fill in a text field by label without for" do
        @session.fill_in('Street', :with => 'Avenue Q')
        @session.click_button('awesome')
        extract_results(@session)['street'].should == 'Avenue Q'
      end
      
      it "should favour exact label matches over partial matches" do
        @session.fill_in('Name', :with => 'Harry Jones')
        @session.click_button('awesome')
        extract_results(@session)['name'].should == 'Harry Jones'
      end

      it "should fill in a textarea by id" do
        @session.fill_in('form_description', :with => 'Texty text')
        @session.click_button('awesome')
        extract_results(@session)['description'].should == 'Texty text'
      end

      it "should fill in a textarea by label" do
        @session.fill_in('Description', :with => 'Texty text')
        @session.click_button('awesome')
        extract_results(@session)['description'].should == 'Texty text'
      end

      it "should fill in a password field by id" do
        @session.fill_in('form_password', :with => 'supasikrit')
        @session.click_button('awesome')
        extract_results(@session)['password'].should == 'supasikrit'
      end

      it "should fill in a password field by label" do
        @session.fill_in('Password', :with => 'supasikrit')
        @session.click_button('awesome')
        extract_results(@session)['password'].should == 'supasikrit'
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running do
            @session.fill_in('does not exist', :with => 'Blah blah')
          end.should raise_error(Capybara::ElementNotFound)
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
            @session.fill_in('First Name', :with => 'Blah blah')
          end.should raise_error(Capybara::LocateHiddenElementError)
        end
      end
    end
  end
end  
