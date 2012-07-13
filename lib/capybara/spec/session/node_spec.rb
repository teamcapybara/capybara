shared_examples_for "node" do
  describe "node" do
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
    end

    describe "#set" do
      it "should allow assignment of field value" do
        @session.first('//input').value.should == 'monkey'
        @session.first('//input').set('gorilla')
        @session.first('//input').value.should == 'gorilla'
      end
    end

    describe "#tag_name" do
      it "should extract node tag name" do
        @session.all('//a')[0].tag_name.should == 'a'
        @session.all('//a')[1].tag_name.should == 'a'
        @session.all('//p')[1].tag_name.should == 'p'
      end
    end

    describe "#visible?" do
      it "should extract node visibility" do
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
    end

  end
end
