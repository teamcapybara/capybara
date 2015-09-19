Capybara::SpecHelper.spec '#find_field' do
  before do
    @session.visit('/form')
  end

  it "should find any field" do
    expect(@session.find_field('Dog').value).to eq('dog')
    expect(@session.find_field('form_description').text).to eq('Descriptive text goes here')
    expect(@session.find_field('Region')[:name]).to eq('form[region]')
  end

  it "casts to string" do
    expect(@session.find_field(:'Dog').value).to eq('dog')
  end

  it "should raise error if the field doesn't exist" do
    expect do
      @session.find_field('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  it "should warn if filter option is invalid" do
    expect_any_instance_of(Kernel).to receive(:warn).
      with('Invalid value nil passed to filter disabled - defaulting to false')
    @session.find_field('Dog', disabled: nil)
  end

  it "should be aliased as 'field_labeled' for webrat compatibility" do
    expect(@session.field_labeled('Dog').value).to eq('dog')
    expect do
      @session.field_labeled('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      expect(@session.find_field("Explanation", :exact => false)[:name]).to eq("form[name_explanation]")
    end

    it "should not accept partial matches when true" do
      expect do
        @session.find_field("Explanation", :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :disabled option" do
    it "should find disabled fields when true" do
      expect(@session.find_field("Disabled Checkbox", :disabled => true)[:name]).to eq("form[disabled_checkbox]")
    end

    it "should not find disabled fields when false" do
      expect do
        @session.find_field("Disabled Checkbox", :disabled => false)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "should not find disabled fields by default" do
      expect do
        @session.find_field("Disabled Checkbox")
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "should find disabled fields when :all" do
      expect(@session.find_field("Disabled Checkbox", :disabled => :all)[:name]).to eq("form[disabled_checkbox]")
    end

    it "should find enabled fields when :all" do
      expect(@session.find_field('Dog', :disabled => :all).value).to eq('dog')
    end
  end


  context 'with :readonly option' do
    it "should find readonly fields when true" do
      expect(@session.find_field('form[readonly_test]', readonly: true)[:id]).to eq 'readonly'
    end

    it "should not find readonly fields when false" do
      expect(@session.find_field('form[readonly_test]', readonly: false)[:id]).to eq 'not_readonly'
    end

    it "should ignore readonly by default" do
      expect do
        @session.find_field('form[readonly_test]')
      end.to raise_error(Capybara::Ambiguous, /found 2 elements/)
    end
  end
end
