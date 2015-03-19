Capybara::SpecHelper.spec Capybara::Selector do
  before do
    @session.visit('/form')
  end

  describe ":label selector" do
    it "finds a label by text" do
      expect(@session.find(:label, 'Customer Name').text).to eq 'Customer Name'
    end

    it "finds a label by for attribute" do
      expect(@session.find(:label, 'form_other_title')['for']).to eq 'form_other_title'
    end

    it "finds a label from nested input when called with that input" do
      input = @session.find(:id, 'nested_label')
      expect(@session.find(:label, input).text).to eq 'Nested Label'
    end

    it "finds the label for an element when called with that element using 'for' attribute" do
      select = @session.find(:id, 'form_other_title')
      expect(@session.find(:label, select)['for']).to eq 'form_other_title'
    end

    context "with exact option" do
      it "matches substrings" do
        expect(@session.find(:label, 'Customer Na', exact: false).text).to eq 'Customer Name'
      end

      it "doesn't match substrings" do
        expect { @session.find(:label, 'Customer Na', exact: true) }.to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end