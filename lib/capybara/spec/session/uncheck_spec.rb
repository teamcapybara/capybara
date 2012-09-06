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
end
