Capybara::SpecHelper.spec '#find_field' do
  before do
    @session.visit('/form')
  end

  it "should find any field" do
    @session.find_field('Dog').value.should == 'dog'
    @session.find_field('form_description').text.should == 'Descriptive text goes here'
    @session.find_field('Region')[:name].should == 'form[region]'
  end

  it "casts to string" do
    @session.find_field(:'Dog').value.should == 'dog'
  end

  it "should raise error if the field doesn't exist" do
    expect do
      @session.find_field('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  it "should be aliased as 'field_labeled' for webrat compatibility" do
    @session.field_labeled('Dog').value.should == 'dog'
    expect do
      @session.field_labeled('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.find_field("Explanation", :exact => false)[:name].should == "form[name_explanation]"
    end

    it "should not accept partial matches when true" do
      expect do
        @session.find_field("Explanation", :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :disabled option" do
    it "should find disabled fields when true" do
      @session.find_field("Disabled Checkbox", :disabled => true)[:name].should == "form[disabled_checkbox]"
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
  end
end
