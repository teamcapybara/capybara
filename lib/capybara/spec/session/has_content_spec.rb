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

    it "should ignore extra whitespace and newlines" do
      @session.visit('/with_html')
      @session.should have_content('text with whitespace')
      @session.should have_content(%|text with\n whitespace|)
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

    it 'should be true if content is in the title tag in the head' do
      @session.visit('/with_js')
      @session.should have_content('with_js')
    end

    it 'should be true if content is inside a script tag in the body' do
      @session.visit('/with_js')
      @session.should have_content('a javascript comment')
      @session.should have_content('aVar')
    end

    it "should be true if the given content is on the page but not visible" do
      @session.visit('/with_html')
      @session.should have_content('Inside element with hidden ancestor')
    end
  end

  describe '#has_no_content?' do
    it "should be false if the given content is on the page at least once" do
      @session.visit('/with_html')
      @session.should_not have_no_content('est')
      @session.should_not have_no_content('Lorem')
      @session.should_not have_no_content('Redirect')
    end

    it "should be false if scoped to an element which has the content" do
      @session.visit('/with_html')
      @session.within("//a[@title='awesome title']") do
        @session.should_not have_no_content('labore')
      end
    end

    it "should be true if scoped to an element which does not have the content" do
      @session.visit('/with_html')
      @session.within("//a[@title='awesome title']") do
        @session.should have_no_content('monkey')
      end
    end

    it "should ignore tags" do
      @session.visit('/with_html')
      @session.should have_no_content('exercitation <a href="/foo" id="foo">ullamco</a> laboris')
      @session.should_not have_no_content('exercitation ullamco laboris')
    end

    it "should be true if the given content is not on the page" do
      @session.visit('/with_html')
      @session.should have_no_content('xxxxyzzz')
      @session.should have_no_content('monkey')
    end

    it 'should handle single quotes in the content' do
      @session.visit('/with-quotes')
      @session.should_not have_no_content("can't")
    end

    it 'should handle double quotes in the content' do
      @session.visit('/with-quotes')
      @session.should_not have_no_content(%q{"No," he said})
    end

    it 'should handle mixed single and double quotes in the content' do
      @session.visit('/with-quotes')
      @session.should_not have_no_content(%q{"you can't do that."})
    end

    it 'should be false if content is in the title tag in the head' do
      @session.visit('/with_js')
      @session.should_not have_no_content('with_js')
    end

    it 'should be false if content is inside a script tag in the body' do
      @session.visit('/with_js')
      @session.should_not have_no_content('a javascript comment')
      @session.should_not have_no_content('aVar')
    end

    it "should be false if the given content is on the page but not visible" do
      @session.visit('/with_html')
      @session.should_not have_no_content('Inside element with hidden ancestor')
    end
  end
end
