Capybara::SpecHelper.spec '#has_text?' do
  it "should be true if the given text is on the page at least once" do
    @session.visit('/with_html')
    @session.should have_text('est')
    @session.should have_text('Lorem')
    @session.should have_text('Redirect')
    @session.should have_text(:'Redirect')
  end

  it "should be true if scoped to an element which has the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      @session.should have_text('labore')
    end
  end

  it "should be false if scoped to an element which does not have the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      @session.should_not have_text('monkey')
    end
  end

  it "should ignore tags" do
    @session.visit('/with_html')
    @session.should_not have_text('exercitation <a href="/foo" id="foo">ullamco</a> laboris')
    @session.should have_text('exercitation ullamco laboris')
  end

  it "should ignore extra whitespace and newlines" do
    @session.visit('/with_html')
    @session.should have_text('text with whitespace')
  end

  it "should ignore whitespace and newlines in the search string" do
    @session.visit('/with_html')
    @session.should have_text("text     with \n\n whitespace")
  end

  it "should be false if the given text is not on the page" do
    @session.visit('/with_html')
    @session.should_not have_text('xxxxyzzz')
    @session.should_not have_text('monkey')
  end

  it 'should handle single quotes in the text' do
    @session.visit('/with-quotes')
    @session.should have_text("can't")
  end

  it 'should handle double quotes in the text' do
    @session.visit('/with-quotes')
    @session.should have_text(%q{"No," he said})
  end

  it 'should handle mixed single and double quotes in the text' do
    @session.visit('/with-quotes')
    @session.should have_text(%q{"you can't do that."})
  end

  it 'should be false if text is in the title tag in the head' do
    @session.visit('/with_js')
    @session.should_not have_text('with_js')
  end

  it 'should be false if text is inside a script tag in the body' do
    @session.visit('/with_js')
    @session.should_not have_text('a javascript comment')
    @session.should_not have_text('aVar')
  end

  it "should be false if the given text is on the page but not visible" do
    @session.visit('/with_html')
    @session.should_not have_text('Inside element with hidden ancestor')
  end

  it "should be true if the text in the page matches given regexp" do
    @session.visit('/with_html')
    @session.should have_text(/Lorem/)
  end

  it "should be false if the text in the page doesn't match given regexp" do
    @session.visit('/with_html')
    @session.should_not have_text(/xxxxyzzz/)
  end

  it "should escape any characters that would have special meaning in a regexp" do
    @session.visit('/with_html')
    @session.should_not have_text('.orem')
  end

  it "should accept non-string parameters" do
    @session.visit('/with_html')
    @session.should have_text(42)
  end

  it "should be true when passed nil" do
    # Historical behavior; no particular reason other than compatibility.
    @session.visit('/with_html')
    @session.should have_text(nil)
  end

  it "should wait for text to appear", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.should have_text("Has been clicked")
  end
end

Capybara::SpecHelper.spec '#has_no_text?' do
  it "should be false if the given text is on the page at least once" do
    @session.visit('/with_html')
    @session.should_not have_no_text('est')
    @session.should_not have_no_text('Lorem')
    @session.should_not have_no_text('Redirect')
  end

  it "should be false if scoped to an element which has the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      @session.should_not have_no_text('labore')
    end
  end

  it "should be true if scoped to an element which does not have the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      @session.should have_no_text('monkey')
    end
  end

  it "should ignore tags" do
    @session.visit('/with_html')
    @session.should have_no_text('exercitation <a href="/foo" id="foo">ullamco</a> laboris')
    @session.should_not have_no_text('exercitation ullamco laboris')
  end

  it "should be true if the given text is not on the page" do
    @session.visit('/with_html')
    @session.should have_no_text('xxxxyzzz')
    @session.should have_no_text('monkey')
  end

  it 'should handle single quotes in the text' do
    @session.visit('/with-quotes')
    @session.should_not have_no_text("can't")
  end

  it 'should handle double quotes in the text' do
    @session.visit('/with-quotes')
    @session.should_not have_no_text(%q{"No," he said})
  end

  it 'should handle mixed single and double quotes in the text' do
    @session.visit('/with-quotes')
    @session.should_not have_no_text(%q{"you can't do that."})
  end

  it 'should be true if text is in the title tag in the head' do
    @session.visit('/with_js')
    @session.should have_no_text('with_js')
  end

  it 'should be true if text is inside a script tag in the body' do
    @session.visit('/with_js')
    @session.should have_no_text('a javascript comment')
    @session.should have_no_text('aVar')
  end

  it "should be true if the given text is on the page but not visible" do
    @session.visit('/with_html')
    @session.should have_no_text('Inside element with hidden ancestor')
  end

  it "should be true if the text in the page doesn't match given regexp" do
    @session.visit('/with_html')
    @session.should have_no_text(/xxxxyzzz/)
  end

  it "should be false if the text in the page  matches given regexp" do
    @session.visit('/with_html')
    @session.should_not have_no_text(/Lorem/)
  end

  it "should escape any characters that would have special meaning in a regexp" do
    @session.visit('/with_html')
    @session.should have_no_text('.orem')
  end

  it "should wait for text to disappear", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.should have_no_text("I changed it")
  end
end
