# frozen_string_literal: true
Capybara::SpecHelper.spec "#uncheck" do
  before do
    @session.visit('/form')
  end

  it "should uncheck a checkbox by id" do
    @session.uncheck("form_pets_hamster")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog')
    expect(extract_results(@session)['pets']).not_to include('hamster')
  end

  it "should uncheck a checkbox by label" do
    @session.uncheck("Hamster")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog')
    expect(extract_results(@session)['pets']).not_to include('hamster')
  end

  it "casts to string" do
    @session.uncheck(:"form_pets_hamster")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog')
    expect(extract_results(@session)['pets']).not_to include('hamster')
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.uncheck('Ham', exact:  false)
      @session.click_button('awesome')
      expect(extract_results(@session)['pets']).not_to include('hamster')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.uncheck('Ham', exact:  true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "when checkbox hidden" do
    context "with Capybara.automatic_label_click == true" do
      around do |spec|
        old_click_label, Capybara.automatic_label_click = Capybara.automatic_label_click, true
        spec.run
        Capybara.automatic_label_click = old_click_label
      end

      it "should uncheck via clicking the label with :for attribute if possible" do
        expect(@session.find(:checkbox, 'form_cars_jaguar', checked: true, visible: :hidden)).to be
        @session.uncheck('form_cars_jaguar')
        @session.click_button('awesome')
        expect(extract_results(@session)['cars']).not_to include('jaguar')
      end

      it "should uncheck via clicking the wrapping label if possible" do
        expect(@session.find(:checkbox, 'form_cars_koenigsegg', checked: true, visible: :hidden)).to be
        @session.uncheck('form_cars_koenigsegg')
        @session.click_button('awesome')
        expect(extract_results(@session)['cars']).not_to include('koenigsegg')
      end

      it "should not click the label if unneeded" do
        expect(@session.find(:checkbox, 'form_cars_tesla', unchecked: true, visible: :hidden)).to be
        @session.uncheck('form_cars_tesla')
        @session.click_button('awesome')
        expect(extract_results(@session)['cars']).not_to include('tesla')
      end

      it "should raise original error when no label available" do
        expect { @session.uncheck('form_cars_ariel') }.to raise_error(Capybara::ElementNotFound, 'Unable to find checkbox "form_cars_ariel"')
      end

      it "should raise error if not allowed to click label" do
        expect{@session.uncheck('form_cars_jaguar', allow_label_click: false)}.to raise_error(Capybara::ElementNotFound, 'Unable to find checkbox "form_cars_jaguar"')
      end
    end
  end
end
