module HasContentSpec
  shared_examples_for "has_content" do
    describe '#has_content?' do
      it "should be true if the given content is on the page at least once" do
        @session.visit('/with_html')
        @session.should have_content('est')
        @session.should have_content('Lorem')
        @session.should have_content('Redirect')
      end

      it "should be true if scoped to an element which has the content" do
        @session.visit('/with_html')
        @session.within("//a[@title='awesome title']") do
          @session.should have_content('labore')
        end
      end

      it "should be false if scoped to an element which does not have the content" do
        @session.visit('/with_html')
        @session.within("//a[@title='awesome title']") do
          @session.should_not have_content('monkey')
        end
      end

      it "should ignore tags" do
        @session.visit('/with_html')
        @session.should_not have_content('exercitation <a href="/foo" id="foo">ullamco</a> laboris')
        @session.should have_content('exercitation ullamco laboris')
      end

      it "should be false if the given content is not on the page" do
        @session.visit('/with_html')
        @session.should_not have_content('xxxxyzzz')
        @session.should_not have_content('monkey')
      end

      it 'should handle single quotes in the content' do
        @session.visit('/with-quotes')
        @session.should have_content("can't")
      end

      it 'should handle double quotes in the content' do
        @session.visit('/with-quotes')
        @session.should have_content(%q{"No," he said})
      end

      it 'should handle mixed single and double quotes in the content' do
        @session.visit('/with-quotes')
        @session.should have_content(%q{"you can't do that."})
      end
    end
  end
end