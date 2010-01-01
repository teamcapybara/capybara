module ClickLinkSpec
  shared_examples_for "click_link" do
    describe '#click_link' do
      before do
        @session.visit('/with_html')
      end

      context "with id given" do
        it "should take user to the linked page" do
          @session.click_link('foo')
          @session.body.should include('Another World')
        end
      end

      context "with text given" do
        it "should take user to the linked page" do
          @session.click_link('labore')
          @session.body.should include('Bar')
        end
      end

      context "with title given" do
        it "should take user to the linked page" do
          @session.click_link('awesome title')
          @session.body.should include('Bar')
        end
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running do
            @session.click_link('does not exist')
          end.should raise_error(Capybara::ElementNotFound)
        end
      end

      it "should follow redirects" do
        @session.click_link('Redirect')
        @session.body.should include('You landed')
      end
    end
  end
end  