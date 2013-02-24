Capybara::SpecHelper.spec "#uncheck" do
  before do
    @session.visit('/form')
  end

  it "should uncheck a checkbox by id" do
    @session.uncheck("form_pets_hamster")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog')
    extract_results(@session)['pets'].should_not include('hamster')
  end

  it "should uncheck a checkbox by label" do
    @session.uncheck("Hamster")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog')
    extract_results(@session)['pets'].should_not include('hamster')
  end

  it "casts to string" do
    @session.uncheck(:"form_pets_hamster")
    @session.click_button('awesome')
    extract_results(@session)['pets'].should include('dog')
    extract_results(@session)['pets'].should_not include('hamster')
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.uncheck('Ham', :exact => false)
      @session.click_button('awesome')
      extract_results(@session)['pets'].should_not include('hamster')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.uncheck('Ham', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
