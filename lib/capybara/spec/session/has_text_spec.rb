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

  it "should be true if :all given and text is invisible." do
    @session.visit('/with_html')
    @session.should have_text(:all, 'Some of this text is hidden!')
  end

  it "should be true if `Capybara.ignore_hidden_elements = true` and text is invisible." do
    Capybara.ignore_hidden_elements = false
    @session.visit('/with_html')
    @session.should have_text('Some of this text is hidden!')
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

  context "with between" do
    it "should be true if the text occurs within the range given" do
      @session.visit('/with_count')
      @session.should have_text('count', between: 1..3)
      @session.should have_text(/count/, between: 2..2)
    end

    it "should be false if the text occurs more or fewer times than range" do
      @session.visit('/with_count')
      @session.should_not have_text('count', between: 0..1)
      @session.should_not have_text('count', between: 3..10)
      @session.should_not have_text(/count/, between: 2...2)
    end
  end

  context "with count" do
    it "should be true if the text occurs the given number of times" do
      @session.visit('/with_count')
      @session.should have_text('count', count: 2)
    end

    it "should be false if the text occurs a different number of times than the given" do
      @session.visit('/with_count')
      @session.should_not have_text('count', count: 0)
      @session.should_not have_text('count', count: 1)
      @session.should_not have_text(/count/, count: 3)
    end

    it "should coerce count to an integer" do
      @session.visit('/with_count')
      @session.should have_text('count', count: '2')
      @session.should_not have_text('count', count: '3')
    end
  end

  context "with maximum" do
    it "should be true when text occurs same or fewer times than given" do
      @session.visit('/with_count')
      @session.should have_text('count', maximum: 2)
      @session.should have_text(/count/, maximum: 3)
    end

    it "should be false when text occurs more times than given" do
      @session.visit('/with_count')
      @session.should_not have_text('count', maximum: 1)
      @session.should_not have_text('count', maximum: 0)
    end

    it "should coerce maximum to an integer" do
      @session.visit('/with_count')
      @session.should have_text('count', maximum: '2')
      @session.should_not have_text('count', maximum: '1')
    end
  end

  context "with minimum" do
    it "should be true when text occurs same or more times than given" do
      @session.visit('/with_count')
      @session.should have_text('count', minimum: 2)
      @session.should have_text(/count/, minimum: 0)
    end

    it "should be false when text occurs fewer times than given" do
      @session.visit('/with_count')
      @session.should_not have_text('count', minimum: 3)
    end

    it "should coerce minimum to an integer" do
      @session.visit('/with_count')
      @session.should have_text('count', minimum: '2')
      @session.should_not have_text('count', minimum: '3')
    end
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

  it "should be false if :all given and text is invisible." do
    @session.visit('/with_html')
    @session.should_not have_no_text(:all, 'Some of this text is hidden!')
  end

  it "should be false if `Capybara.ignore_hidden_elements = true` and text is invisible." do
    Capybara.ignore_hidden_elements = false
    @session.visit('/with_html')
    @session.should_not have_no_text('Some of this text is hidden!')
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
