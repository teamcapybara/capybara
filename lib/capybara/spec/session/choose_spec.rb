# frozen_string_literal: true

Capybara::SpecHelper.spec "#choose" do
  before do
    @session.visit('/form')
  end

  it "should choose a radio button by id" do
    @session.choose("gender_male")
    @session.click_button('awesome')
    expect(extract_results(@session)['gender']).to eq('male')
  end

  it "should choose a radio button by label" do
    @session.choose("Both")
    @session.click_button('awesome')
    expect(extract_results(@session)['gender']).to eq('both')
  end

  it "should work without a locator string" do
    @session.choose(id: "gender_male")
    @session.click_button('awesome')
    expect(extract_results(@session)['gender']).to eq('male')
  end

  it "casts to string" do
    @session.choose("Both")
    @session.click_button(:awesome)
    expect(extract_results(@session)['gender']).to eq('both')
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find visible radio button \"does not exist\" that is not disabled"
      expect do
        @session.choose('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a disabled radio button" do
    it "should raise an error" do
      expect do
        @session.choose('Disabled Radio')
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.choose("Mal", exact: false)
      @session.click_button('awesome')
      expect(extract_results(@session)['gender']).to eq('male')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.choose("Mal", exact: true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with `option` option" do
    it "can check radio buttons by their value" do
      @session.choose('form[gender]', option: "male")
      @session.click_button('awesome')
      expect(extract_results(@session)['gender']).to eq("male")
    end

    it "should raise an error if option not found" do
      expect do
        @session.choose('form[gender]', option: "hermaphrodite")
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with hidden radio buttons" do
    context "with Capybara.automatic_label_click == true" do
      around do |spec|
        old_click_label, Capybara.automatic_label_click = Capybara.automatic_label_click, true
        spec.run
        Capybara.automatic_label_click = old_click_label
      end

      it "should select by clicking the link if available" do
        @session.choose("party_democrat")
        @session.click_button('awesome')
        expect(extract_results(@session)['party']).to eq('democrat')
      end

      it "should raise error if not allowed to click label" do
        expect { @session.choose("party_democrat", allow_label_click: false) }.to raise_error(Capybara::ElementNotFound, 'Unable to find visible radio button "party_democrat" that is not disabled')
      end
    end
  end

  it "should return the chosen radio button" do
    el = @session.find(:radio_button, 'gender_male')
    expect(@session.choose("gender_male")).to eq el
  end
end
