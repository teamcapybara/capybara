Capybara::SpecHelper.spec "#select" do
  before do
    @session.visit('/form')
  end

  it "should return value of the first option" do
    @session.find_field('Title').value.should == 'Mrs'
  end

  it "should return value of the selected option" do
    @session.select("Miss", :from => 'Title')
    @session.find_field('Title').value.should == 'Miss'
  end

  it "should allow selecting options where there are inexact matches" do
    @session.select("Mr", :from => 'Title')
    @session.find_field('Title').value.should == 'Mr'
  end

  it "should allow selecting options where they are the only inexact match" do
    @session.select("Mis", :from => 'Title')
    @session.find_field('Title').value.should == 'Miss'
  end

  it "should not allow selecting options where they are the only inexact match if `Capybara.exact_options = true`" do
    Capybara.exact_options = true
    expect do
      @session.select("Mis", :from => 'Title')
    end.to raise_error(Capybara::ElementNotFound)
  end

  it "should not allow selecting an option if the match is ambiguous" do
    expect do
      @session.select("M", :from => 'Title')
    end.to raise_error(Capybara::Ambiguous)
  end

  it "should return the value attribute rather than content if present" do
    @session.find_field('Locale').value.should == 'en'
  end

  it "should select an option from a select box by id" do
    @session.select("Finish", :from => 'form_locale')
    @session.click_button('awesome')
    extract_results(@session)['locale'].should == 'fi'
  end

  it "should select an option from a select box by label" do
    @session.select("Finish", :from => 'Locale')
    @session.click_button('awesome')
    extract_results(@session)['locale'].should == 'fi'
  end

  it "should select an option without giving a select box" do
    @session.select("Swedish")
    @session.click_button('awesome')
    extract_results(@session)['locale'].should == 'sv'
  end

  it "should escape quotes" do
    @session.select("John's made-up language", :from => 'Locale')
    @session.click_button('awesome')
    extract_results(@session)['locale'].should == 'jo'
  end

  it "should obey from" do
    @session.select("Miss", :from => "Other title")
    @session.click_button('awesome')
    results = extract_results(@session)
    results['other_title'].should == "Miss"
    results['title'].should_not == "Miss"
  end

  it "show match labels with preceding or trailing whitespace" do
    @session.select("Lojban", :from => 'Locale')
    @session.click_button('awesome')
    extract_results(@session)['locale'].should == 'jbo'
  end

  it "casts to string" do
    @session.select(:"Miss", :from => :'Title')
    @session.find_field('Title').value.should == 'Miss'
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find select box \"does not exist\""
      expect do
        @session.select('foo', :from => 'does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with an option that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find option \"Does not Exist\""
      expect do
        @session.select('Does not Exist', :from => 'form_locale')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "on a disabled select" do
    it "should raise an error" do
      expect do
        @session.select('Should not see me', :from => 'Disabled Select')
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with multiple select" do
    it "should return an empty value" do
      @session.find_field('Language').value.should == []
    end

    it "should return value of the selected options" do
      @session.select("Ruby",       :from => 'Language')
      @session.select("Javascript", :from => 'Language')
      @session.find_field('Language').value.should include('Ruby', 'Javascript')
    end

    it "should select one option" do
      @session.select("Ruby", :from => 'Language')
      @session.click_button('awesome')
      extract_results(@session)['languages'].should == ['Ruby']
    end

    it "should select multiple options" do
      @session.select("Ruby",       :from => 'Language')
      @session.select("Javascript", :from => 'Language')
      @session.click_button('awesome')
      extract_results(@session)['languages'].should include('Ruby', 'Javascript')
    end

    it "should remain selected if already selected" do
      @session.select("Ruby",       :from => 'Language')
      @session.select("Javascript", :from => 'Language')
      @session.select("Ruby",       :from => 'Language')
      @session.click_button('awesome')
      extract_results(@session)['languages'].should include('Ruby', 'Javascript')
    end

    it "should return value attribute rather than content if present" do
      @session.find_field('Underwear').value.should include('thermal')
    end
  end

  context "with :exact option" do
    context "when `false`" do
      it "can match select box approximately" do
        @session.select("Finish", :from => "Loc", :exact => false)
        @session.click_button("awesome")
        extract_results(@session)["locale"].should == "fi"
      end

      it "can match option approximately" do
        @session.select("Fin", :from => "Locale", :exact => false)
        @session.click_button("awesome")
        extract_results(@session)["locale"].should == "fi"
      end

      it "can match option approximately when :from not given" do
        @session.select("made-up language", :exact => false)
        @session.click_button("awesome")
        extract_results(@session)["locale"].should == "jo"
      end
    end

    context "when `true`" do
      it "can match select box approximately" do
        expect do
          @session.select("Finish", :from => "Loc", :exact => true)
        end.to raise_error(Capybara::ElementNotFound)
      end

      it "can match option approximately" do
        expect do
          @session.select("Fin", :from => "Locale", :exact => true)
        end.to raise_error(Capybara::ElementNotFound)
      end

      it "can match option approximately when :from not given" do
        expect do
          @session.select("made-up language", :exact => true)
        end.to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
