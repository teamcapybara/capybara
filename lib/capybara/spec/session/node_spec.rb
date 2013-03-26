Capybara::SpecHelper.spec "node" do
  before do
    @session.visit('/with_html')
  end

  it "should act like a session object" do
    @session.visit('/form')
    @form = @session.find(:css, '#get-form')
    @form.should have_field('Middle Name')
    @form.should have_no_field('Languages')
    @form.fill_in('Middle Name', :with => 'Monkey')
    @form.click_button('med')
    extract_results(@session)['middle_name'].should == 'Monkey'
  end

  it "should scope CSS selectors" do
    @session.find(:css, '#second').should have_no_css('h1')
  end

  describe "#parent" do
    it "should have a reference to its parent if there is one" do
      @node = @session.find(:css, '#first')
      @node.parent.should == @node.session.document
      @node.find(:css, '#foo').parent.should == @node
    end
  end

  describe "#text" do
    it "should extract node texts" do
      @session.all('//a')[0].text.should == 'labore'
      @session.all('//a')[1].text.should == 'ullamco'
    end

    it "should return document text on /html selector" do
      @session.visit('/with_simple_html')
      @session.all('/html')[0].text.should == 'Bar'
    end
  end

  describe "#[]" do
    it "should extract node attributes" do
      @session.all('//a')[0][:class].should == 'simple'
      @session.all('//a')[1][:id].should == 'foo'
      @session.all('//input')[0][:type].should == 'text'
    end

    it "should extract boolean node attributes" do
      @session.find('//input[@id="checked_field"]')[:checked].should be_true
    end
  end

  describe "#value" do
    it "should allow retrieval of the value" do
      @session.find('//textarea[@id="normal"]').value.should == 'banana'
    end

    it "should not swallow extra newlines in textarea" do
      @session.find('//textarea[@id="additional_newline"]').value.should == "\nbanana"
    end

    it "return any HTML content in textarea" do
      @session.find('//textarea[1]').set("some <em>html</em> here")
      @session.find('//textarea[1]').value.should == "some <em>html</em> here"
    end
  end

  describe "#set" do
    it "should allow assignment of field value" do
      @session.first('//input').value.should == 'monkey'
      @session.first('//input').set('gorilla')
      @session.first('//input').value.should == 'gorilla'
    end

    it "should fill the field even if the caret was not at the end", :requires => [:js] do
      @session.execute_script("var el = document.getElementById('test_field'); el.focus(); el.setSelectionRange(0, 0);")
      @session.first('//input').set('')
      @session.first('//input').value.should == ''
    end

    it "should not set if the text field is readonly" do
      @session.first('//input[@readonly]').value.should == 'should not change'
      @session.first('//input[@readonly]').set('changed')
      @session.first('//input[@readonly]').value.should == 'should not change'
    end

    it "should not set if the textarea is readonly" do
      @session.first('//textarea[@readonly]').value.should == 'textarea should not change'
      @session.first('//textarea[@readonly]').set('changed')
      @session.first('//textarea[@readonly]').value.should == 'textarea should not change'
    end
  end

  describe "#tag_name" do
    it "should extract node tag name" do
      @session.all('//a')[0].tag_name.should == 'a'
      @session.all('//a')[1].tag_name.should == 'a'
      @session.all('//p')[1].tag_name.should == 'p'
    end
  end

  describe "#disabled?" do
    it "should extract disabled node" do
      @session.visit('/form')
      @session.find('//input[@id="customer_name"]').should be_disabled
      @session.find('//input[@id="customer_email"]').should_not be_disabled
    end

    it "should see disabled options as disabled" do
      @session.visit('/form')
      @session.find('//select[@id="form_title"]/option[1]').should_not be_disabled
      @session.find('//select[@id="form_title"]/option[@disabled]').should be_disabled
    end

    it "should see enabled options in disabled select as disabled" do
      @session.visit('/form')
      @session.find('//select[@id="form_disabled_select"]/option').should be_disabled
      @session.find('//select[@id="form_title"]/option[1]').should_not be_disabled
    end
  end

  describe "#visible?" do
    it "should extract node visibility" do
      Capybara.ignore_hidden_elements = false
      @session.first('//a').should be_visible

      @session.find('//div[@id="hidden"]').should_not be_visible
      @session.find('//div[@id="hidden_via_ancestor"]').should_not be_visible
    end
  end

  describe "#checked?" do
    it "should extract node checked state" do
      @session.visit('/form')
      @session.find('//input[@id="gender_female"]').should be_checked
      @session.find('//input[@id="gender_male"]').should_not be_checked
      @session.first('//h1').should_not be_checked
    end
  end

  describe "#selected?" do
    it "should extract node selected state" do
      @session.visit('/form')
      @session.find('//option[@value="en"]').should be_selected
      @session.find('//option[@value="sv"]').should_not be_selected
      @session.first('//h1').should_not be_selected
    end
  end

  describe "#==" do
    it "preserve object identity" do
      (@session.find('//h1') == @session.find('//h1')).should be_true
      (@session.find('//h1') === @session.find('//h1')).should be_true
      (@session.find('//h1').eql? @session.find('//h1')).should be_false
    end

    it "returns false for unrelated object" do
      (@session.find('//h1') == "Not Capybara::Node::Base").should be_false
    end
  end

  describe "#trigger", :requires => [:js, :trigger] do
    it "should allow triggering of custom JS events" do
      @session.visit('/with_js')
      @session.find(:css, '#with_focus_event').trigger(:focus)
      @session.should have_css('#focus_event_triggered')
    end
  end

  describe '#drag_to', :requires => [:js, :drag] do
    it "should drag and drop an object" do
      @session.visit('/with_js')
      element = @session.find('//div[@id="drag"]')
      target = @session.find('//div[@id="drop"]')
      element.drag_to(target)
      @session.find('//div[contains(., "Dropped!")]').should_not be_nil
    end
  end

  describe '#hover', :requires => [:hover] do
    it "should allow hovering on an element" do
      pending "Selenium with firefox doesn't currently work with this (selenium with chrome does)" if @session.respond_to?(:mode) && @session.mode == :selenium && @session.driver.browser.browser == :firefox
      @session.visit('/with_hover')
      @session.find(:css,'.hidden_until_hover', :visible => false).should_not be_visible
      @session.find(:css,'.wrapper').hover
      @session.find(:css, '.hidden_until_hover', :visible => false).should be_visible
    end
  end

  describe '#reload', :requires => [:js] do
    context "without automatic reload" do
      before { Capybara.automatic_reload = false }
      it "should reload the current context of the node" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        node.reload.text.should == 'has been reloaded'
        node.text.should == 'has been reloaded'
      end

      it "should reload a parent node" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me').find(:css, 'em')
        @session.click_link('Reload!')
        sleep(0.3)
        node.reload.text.should == 'has been reloaded'
        node.text.should == 'has been reloaded'
      end

      it "should not automatically reload" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        expect { node.text.to == 'has been reloaded' }.to raise_error
      end
      after { Capybara.automatic_reload = true }
    end

    context "with automatic reload" do
      it "should reload the current context of the node automatically" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        node.text.should == 'has been reloaded'
      end

      it "should reload a parent node automatically" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me').find(:css, 'em')
        @session.click_link('Reload!')
        sleep(0.3)
        node.text.should == 'has been reloaded'
      end

      it "should reload a node automatically when using find" do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        node.find(:css, 'a').text.should == 'has been reloaded'
      end

      it "should not reload nodes which haven't been found" do
        @session.visit('/with_js')
        node = @session.all(:css, '#the-list li')[1]
        @session.click_link('Fetch new list!')
        sleep(0.3)
        expect { node.text.to == 'Foo' }.to raise_error
        expect { node.text.to == 'Bar' }.to raise_error
      end

      it "should reload nodes with options" do
        @session.visit('/with_js')
        node = @session.find(:css, 'em', :text => "reloaded")
        @session.click_link('Reload!')
        sleep(1)
        node.text.should == 'has been reloaded'
      end
    end
  end
end
