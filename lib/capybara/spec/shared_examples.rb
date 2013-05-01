shared_examples "acknowledge Capybara.before_action" do
  before do
    Capybara.before_action = "before_action_is_called = true"
  end

  context "Capybara.before_action is specified" do

    context "on a driver capable of execute_script" do

      before do
        @session.evaluate_script("before_action_is_called = false" )
      end


      it "calls the before action", :requires => [:js] do
        expect { subject}.to change{@session.evaluate_script('before_action_is_called')}.from(false).to(true)
      end
    end

    context "on a driver not capable of execute_script" do
      it "calls the before action" do
        expect { subject}.to_not raise_error(Capybara::NotSupportedByDriverError)
      end
    end

  end

end

shared_examples "acknowledge Capybara.after_action" do

  before do
    Capybara.after_action = "after_action_is_called = true"
  end

    context "on a driver capable of execute_script" do

      before do
        @session.evaluate_script("after_action_is_called = false" )
      end


      it "calls the after action", :requires => [:js] do
        expect { subject}.to change{@session.evaluate_script('after_action_is_called')}.from(false).to(true)
      end
    end

    context "on a driver not capable of execute_script" do
      it "calls the before action" do
        expect { subject}.to_not raise_error(Capybara::NotSupportedByDriverError)
      end
    end


end
