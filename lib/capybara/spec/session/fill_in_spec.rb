# frozen_string_literal: true
Capybara::SpecHelper.spec "#fill_in" do
  before do
    @session.visit('/form')
  end

  it "should fill in a text field by id" do
    @session.fill_in('form_first_name', with: 'Harry')
    @session.click_button('awesome')
    expect(extract_results(@session)['first_name']).to eq('Harry')
  end

  it "should fill in a text field by name" do
    @session.fill_in('form[last_name]', with: 'Green')
    @session.click_button('awesome')
    expect(extract_results(@session)['last_name']).to eq('Green')
  end

  it "should fill in a text field by label without for" do
    @session.fill_in('First Name', with: 'Harry')
    @session.click_button('awesome')
    expect(extract_results(@session)['first_name']).to eq('Harry')
  end

  it "should fill in a url field by label without for" do
    @session.fill_in('Html5 Url', with: 'http://www.avenueq.com')
    @session.click_button('html5_submit')
    expect(extract_results(@session)['html5_url']).to eq('http://www.avenueq.com')
  end

  it "should fill in a textarea by id" do
    @session.fill_in('form_description', with: 'Texty text')
    @session.click_button('awesome')
    expect(extract_results(@session)['description']).to eq('Texty text')
  end

  it "should fill in a textarea by label" do
    @session.fill_in('Description', with: 'Texty text')
    @session.click_button('awesome')
    expect(extract_results(@session)['description']).to eq('Texty text')
  end

  it "should fill in a textarea by name" do
    @session.fill_in('form[description]', with: 'Texty text')
    @session.click_button('awesome')
    expect(extract_results(@session)['description']).to eq('Texty text')
  end

  it "should fill in a password field by id" do
    @session.fill_in('form_password', with: 'supasikrit')
    @session.click_button('awesome')
    expect(extract_results(@session)['password']).to eq('supasikrit')
  end

  it "should handle HTML in a textarea" do
    @session.fill_in('form_description', with: 'is <strong>very</strong> secret!')
    @session.click_button('awesome')
    expect(extract_results(@session)['description']).to eq('is <strong>very</strong> secret!')
  end

  it "should handle newlines in a textarea" do
    @session.fill_in('form_description', with: "\nSome text\n")
    @session.click_button('awesome')
    expect(extract_results(@session)['description']).to eq("\r\nSome text\r\n")
  end

  it "should fill in a field with a custom type" do
    @session.fill_in('Schmooo', with: 'Schmooo is the game')
    @session.click_button('awesome')
    expect(extract_results(@session)['schmooo']).to eq('Schmooo is the game')
  end

  it "should fill in a field without a type" do
    @session.fill_in('Phone', with: '+1 555 7022')
    @session.click_button('awesome')
    expect(extract_results(@session)['phone']).to eq('+1 555 7022')
  end

  it "should fill in a text field respecting its maxlength attribute" do
    @session.fill_in('Zipcode', with: '52071350')
    @session.click_button('awesome')
    expect(extract_results(@session)['zipcode']).to eq('52071')
  end

  it "should fill in a password field by name" do
    @session.fill_in('form[password]', with: 'supasikrit')
    @session.click_button('awesome')
    expect(extract_results(@session)['password']).to eq('supasikrit')
  end

  it "should fill in a password field by label" do
    @session.fill_in('Password', with: 'supasikrit')
    @session.click_button('awesome')
    expect(extract_results(@session)['password']).to eq('supasikrit')
  end

  it "should fill in a password field by name" do
    @session.fill_in('form[password]', with: 'supasikrit')
    @session.click_button('awesome')
    expect(extract_results(@session)['password']).to eq('supasikrit')
  end

  it "should throw an exception if a hash containing 'with' is not provided" do
    expect {@session.fill_in 'Name', 'ignu'}.to raise_error(RuntimeError, /with/)
  end

  it "should wait for asynchronous load", requires: [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.fill_in('new_field', with: 'Testing...')
  end

  it "casts to string" do
    @session.fill_in(:'form_first_name', with: :'Harry')
    @session.click_button('awesome')
    expect(extract_results(@session)['first_name']).to eq('Harry')
  end

  it "casts to string if field has maxlength" do
    @session.fill_in(:'form_zipcode', with: 1234567)
    @session.click_button('awesome')
    expect(extract_results(@session)['zipcode']).to eq('12345')
  end

  context 'on a pre-populated textfield with a reformatting onchange', requires: [:js] do
    it 'should only trigger onchange once' do
      @session.visit('/with_js')
      @session.fill_in('with_change_event', with: 'some value')
      # click outside the field to trigger the change event
      @session.find(:css, 'body').click
      expect(@session.find(:css, '.change_event_triggered', match: :one)).to have_text 'some value'
    end

    it 'should trigger change when clearing field' do
      @session.visit('/with_js')
      @session.fill_in('with_change_event', with: '')
      # click outside the field to trigger the change event
      @session.find(:css, 'body').click
      expect(@session).to have_selector(:css, '.change_event_triggered', match: :one)
    end
  end

  context "with ignore_hidden_fields" do
    before { Capybara.ignore_hidden_elements = true }
    after  { Capybara.ignore_hidden_elements = false }
    it "should not find a hidden field" do
      msg = "Unable to find field \"Super Secret\""
      expect do
        @session.fill_in('Super Secret', with: '777')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find field \"does not exist\""
      expect do
        @session.fill_in('does not exist', with: 'Blah blah')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "on a disabled field" do
    it "should raise an error" do
      expect do
        @session.fill_in('Disabled Text Field', with: 'Blah blah')
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.fill_in("Explanation", with: "Dude", exact:  false)
      @session.click_button("awesome")
      expect(extract_results(@session)["name_explanation"]).to eq("Dude")
    end

    it "should not accept partial matches when true" do
      expect do
        @session.fill_in("Explanation", with: "Dude", exact:  true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  it "should return the element filled in" do
    el = @session.find(:fillable_field, 'form_first_name')
    expect(@session.fill_in('form_first_name', with: 'Harry')).to eq el
  end
end
