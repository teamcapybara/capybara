Capybara::SpecHelper.spec "#check" do
  before do
    @session.visit('/form')
  end

  describe "'checked' attribute" do
    it "should be true if checked" do
      @session.check("Terms of Use")
      @session.find(:xpath, "//input[@id='form_terms_of_use']")['checked'].should be_true
    end

    it "should be false if unchecked" do
      @session.find(:xpath, "//input[@id='form_terms_of_use']")['checked'].should be_false
    end
  end

  it "should trigger associated events", :requires => [:js] do
    @session.visit('/with_js')
    @session.check('checkbox_with_event')
    @session.should have_css('#checkbox_event_triggered');
  end

  describe "checking" do
    it "should not change an already checked checkbox" do
      @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
      @session.check('form_pets_dog')
      @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
    end

    it "should check an unchecked checkbox" do
      @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
      @session.check('form_pets_cat')
      @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_true
    end
  end

  describe "unchecking" do
    it "should not change an already unchecked checkbox" do
      @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
      @session.uncheck('form_pets_cat')
      @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
    end

    it "should uncheck a checked checkbox" do
      @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
      @session.uncheck('form_pets_dog')
      @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_false
    end
  end

  it "should check a checkbox by id" do
    @session.check("form_pets_cat")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
  end

  it "should check a checkbox by label" do
    @session.check("Cat")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
  end

  it "casts to string" do
    @session.check(:"form_pets_cat")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find checkbox \"does not exist\""
      expect do
        @session.check('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a disabled checkbox" do
    it "should raise an error" do
      expect do
        @session.check('Disabled Checkbox')
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.check('Ham', :exact => false)
      @session.click_button('awesome')
      extract_results(@session)['pets'].should include('hamster')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.check('Ham', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
