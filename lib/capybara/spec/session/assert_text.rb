Capybara::SpecHelper.spec '#assert_text' do
  it "should be true if the given text is on the page" do
    @session.visit('/with_html')
    expect(@session.assert_text('est')).to eq(true)
    expect(@session.assert_text('Lorem')).to eq(true)
    expect(@session.assert_text('Redirect')).to eq(true)
    expect(@session.assert_text(:'Redirect')).to eq(true)
    expect(@session.assert_text('text with whitespace')).to eq(true)
    expect(@session.assert_text("text     with \n\n whitespace")).to eq(true)
  end

  it "should take scopes into account" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      expect(@session.assert_text('labore')).to eq(true)
    end
  end

  it "should raise if scoped to an element which does not have the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      expect do
        @session.assert_text('monkey')
      end.to raise_error(Capybara::ExpectationNotMet, 'expected to find text "monkey" in "labore"')
    end
  end

  it "should be true if :all given and text is invisible." do
    @session.visit('/with_html')
    expect(@session.assert_text(:all, 'Some of this text is hidden!')).to eq(true)
  end

  it "should be true if `Capybara.ignore_hidden_elements = true` and text is invisible." do
    Capybara.ignore_hidden_elements = false
    @session.visit('/with_html')
    expect(@session.assert_text('Some of this text is hidden!')).to eq(true)
  end

  it "should be true if the text in the page matches given regexp" do
    @session.visit('/with_html')
    expect(@session.assert_text(/Lorem/)).to eq(true)
  end

  it "should be raise error if the text in the page doesn't match given regexp" do
    @session.visit('/with_html')
    expect do
      @session.assert_text(/xxxxyzzz/)
    end.to raise_error(Capybara::ExpectationNotMet, /\Aexpected to find text matching \/xxxxyzzz\/ in "This is a test Header Class(.+)"\Z/)
  end

  it "should escape any characters that would have special meaning in a regexp" do
    @session.visit('/with_html')
    expect do
      @session.assert_text('.orem')
    end.to raise_error(Capybara::ExpectationNotMet)
  end

  it "should wait for text to appear", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    expect(@session.assert_text('Has been clicked')).to eq(true)
  end

  context "with between" do
    it "should be true if the text occurs within the range given" do
      @session.visit('/with_count')
      expect(@session.assert_text('count', between: 1..3)).to eq(true)
    end

    it "should be false if the text occurs more or fewer times than range" do
      @session.visit('/with_html')
      expect do
        @session.find(:css, '.number').assert_text(/\d/, between: 0..1)
      end.to raise_error(Capybara::ExpectationNotMet, "expected to find text matching /\\d/ between 0 and 1 times but found 2 times in \"42\"")
    end
  end

  context "with wait", :requires => [:js] do
    it "should find element if it appears before given wait duration" do
      Capybara.using_wait_time(0) do
        @session.visit('/with_js')
        @session.find(:css, '#reload-list').click
        @session.find(:css, '#the-list').assert_text('Foo Bar', wait: 0.9)
      end
    end

    it "should raise error if it appears after given wait duration" do
      Capybara.using_wait_time(0) do
        @session.visit('/with_js')
        @session.find(:css, '#reload-list').click
        el = @session.find(:css, '#the-list', visible: false)
        expect do
          el.assert_text(:all, 'Foo Bar', wait: 0.3)
        end.to raise_error(Capybara::ExpectationNotMet)
      end
    end
  end

  context 'with multiple count filters' do
    before(:each) do
      @session.visit('/with_html')
    end

    it 'ignores other filters when :count is specified' do
      o = {:count   => 5,
           :minimum => 6,
           :maximum => 0,
           :between => 0..4}
      expect { @session.assert_text('Header', o) }.not_to raise_error
    end
    context 'with no :count expectation' do
      it 'fails if :minimum is not met' do
        o = {:minimum => 6,
             :maximum => 5,
             :between => 2..7}
        expect { @session.assert_text('Header', o) }.to raise_error(Capybara::ExpectationNotMet)
      end
      it 'fails if :maximum is not met' do
        o = {:minimum => 0,
             :maximum => 0,
             :between => 2..7}
        expect { @session.assert_text('Header', o) }.to raise_error(Capybara::ExpectationNotMet)
      end
      it 'fails if :between is not met' do
        o = {:minimum => 0,
             :maximum => 5,
             :between => 0..4}
        expect { @session.assert_text('Header', o) }.to raise_error(Capybara::ExpectationNotMet)
      end
      it 'succeeds if all combineable expectations are met' do
        o = {:minimum => 0,
             :maximum => 5,
             :between => 2..7}
        expect { @session.assert_text('Header', o) }.not_to raise_error
      end
    end
  end
end

Capybara::SpecHelper.spec '#assert_no_text' do
  it "should raise error if the given text is on the page at least once" do
    @session.visit('/with_html')
    expect do
      @session.assert_no_text('Lorem')
    end.to raise_error(Capybara::ExpectationNotMet, /\Aexpected not to find text "Lorem" in "This is a test Header Class.+"\Z/)
  end

  it "should be true if scoped to an element which does not have the text" do
    @session.visit('/with_html')
    @session.within("//a[@title='awesome title']") do
      expect(@session.assert_no_text('monkey')).to eq(true)
    end
  end

  it "should be true if the given text is on the page but not visible" do
    @session.visit('/with_html')
    expect(@session.assert_no_text('Inside element with hidden ancestor')).to eq(true)
  end

  it "should raise error if :all given and text is invisible." do
    @session.visit('/with_html')
    el = @session.find(:css, '#hidden-text', visible: false)
    expect do
      el.assert_no_text(:all, 'Some of this text is hidden!')
    end.to raise_error(Capybara::ExpectationNotMet, 'expected not to find text "Some of this text is hidden!" in "Some of this text is hidden!"')
  end

  it "should be true if the text in the page doesn't match given regexp" do
    @session.visit('/with_html')
    @session.assert_no_text(/xxxxyzzz/)
  end

  context "with count" do
    it "should be true if the text occurs within the range given" do
      @session.visit('/with_count')
      expect(@session.assert_text('count', count: 2)).to eq(true)
    end

    it "should be false if the text occurs more or fewer times than range" do
      @session.visit('/with_html')
      expect do
        @session.find(:css, '.number').assert_text(/\d/, count: 1)
      end.to raise_error(Capybara::ExpectationNotMet, "expected to find text matching /\\d/ 1 time but found 2 times in \"42\"")
    end
  end

  context "with wait", :requires => [:js] do
    it "should not find element if it appears after given wait duration" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.find(:css, '#reload-list').click
      @session.find(:css, '#the-list').assert_no_text('Foo Bar', :wait => 0.3)
    end
  end
end
