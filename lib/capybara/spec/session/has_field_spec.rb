Capybara::SpecHelper.spec '#has_field' do
  before { @session.visit('/form') }

  it "should be true if the field is on the page" do
    @session.should have_field('Dog')
    @session.should have_field('form_description')
    @session.should have_field('Region')
    @session.should have_field(:'Region')
  end

  it "should be false if the field is not on the page" do
    @session.should_not have_field('Monkey')
  end

  context 'with value' do
    it "should be true if a field with the given value is on the page" do
      @session.should have_field('First Name', :with => 'John')
      @session.should have_field('Phone', :with => '+1 555 7021')
      @session.should have_field('Street', :with => 'Sesame street 66')
      @session.should have_field('Description', :with => 'Descriptive text goes here')
    end

    it "should be false if the given field is not on the page" do
      @session.should_not have_field('First Name', :with => 'Peter')
      @session.should_not have_field('Wrong Name', :with => 'John')
      @session.should_not have_field('Description', :with => 'Monkey')
    end

    it "should be true after the field has been filled in with the given value" do
      @session.fill_in('First Name', :with => 'Jonas')
      @session.should have_field('First Name', :with => 'Jonas')
    end

    it "should be false after the field has been filled in with a different value" do
      @session.fill_in('First Name', :with => 'Jonas')
      @session.should_not have_field('First Name', :with => 'John')
    end
  end

  context 'with type' do
    it "should be true if a field with the given type is on the page" do
      @session.should have_field('First Name', :type => 'text')
      @session.should have_field('Html5 Email', :type => 'email')
      @session.should have_field('Html5 Tel', :type => 'tel')
      @session.should have_field('Description', :type => 'textarea')
      @session.should have_field('Languages', :type => 'select')
    end

    it "should be false if the given field is not on the page" do
      @session.should_not have_field('First Name', :type => 'textarea')
      @session.should_not have_field('Html5 Email', :type => 'tel')
      @session.should_not have_field('Description', :type => '')
      @session.should_not have_field('Description', :type => 'email')
      @session.should_not have_field('Languages', :type => 'textarea')
    end
  end
end

Capybara::SpecHelper.spec '#has_no_field' do
  before { @session.visit('/form') }

  it "should be false if the field is on the page" do
    @session.should_not have_no_field('Dog')
    @session.should_not have_no_field('form_description')
    @session.should_not have_no_field('Region')
  end

  it "should be true if the field is not on the page" do
    @session.should have_no_field('Monkey')
  end

  context 'with value' do
    it "should be false if a field with the given value is on the page" do
      @session.should_not have_no_field('First Name', :with => 'John')
      @session.should_not have_no_field('Phone', :with => '+1 555 7021')
      @session.should_not have_no_field('Street', :with => 'Sesame street 66')
      @session.should_not have_no_field('Description', :with => 'Descriptive text goes here')
    end

    it "should be true if the given field is not on the page" do
      @session.should have_no_field('First Name', :with => 'Peter')
      @session.should have_no_field('Wrong Name', :with => 'John')
      @session.should have_no_field('Description', :with => 'Monkey')
    end

    it "should be false after the field has been filled in with the given value" do
      @session.fill_in('First Name', :with => 'Jonas')
      @session.should_not have_no_field('First Name', :with => 'Jonas')
    end

    it "should be true after the field has been filled in with a different value" do
      @session.fill_in('First Name', :with => 'Jonas')
      @session.should have_no_field('First Name', :with => 'John')
    end
  end

  context 'with type' do
    it "should be false if a field with the given type is on the page" do
      @session.should_not have_no_field('First Name', :type => 'text')
      @session.should_not have_no_field('Html5 Email', :type => 'email')
      @session.should_not have_no_field('Html5 Tel', :type => 'tel')
      @session.should_not have_no_field('Description', :type => 'textarea')
      @session.should_not have_no_field('Languages', :type => 'select')
    end

    it "should be true if the given field is not on the page" do
      @session.should have_no_field('First Name', :type => 'textarea')
      @session.should have_no_field('Html5 Email', :type => 'tel')
      @session.should have_no_field('Description', :type => '')
      @session.should have_no_field('Description', :type => 'email')
      @session.should have_no_field('Languages', :type => 'textarea')
    end
  end
end

Capybara::SpecHelper.spec '#has_checked_field?' do
  before { @session.visit('/form') }

  it "should be true if a checked field is on the page" do
    @session.should have_checked_field('gender_female')
    @session.should have_checked_field('Hamster')
  end

  it "should be false if an unchecked field is on the page" do
    @session.should_not have_checked_field('form_pets_cat')
    @session.should_not have_checked_field('Male')
  end

  it "should be false if no field is on the page" do
    @session.should_not have_checked_field('Does Not Exist')
  end

  it "should be true after an unchecked checkbox is checked" do
    @session.check('form_pets_cat')
    @session.should have_checked_field('form_pets_cat')
  end

  it "should be false after a checked checkbox is unchecked" do
    @session.uncheck('form_pets_dog')
    @session.should_not have_checked_field('form_pets_dog')
  end

  it "should be true after an unchecked radio button is chosen" do
    @session.choose('gender_male')
    @session.should have_checked_field('gender_male')
  end

  it "should be false after another radio button in the group is chosen" do
    @session.choose('gender_male')
    @session.should_not have_checked_field('gender_female')
  end
end

Capybara::SpecHelper.spec '#has_no_checked_field?' do
  before { @session.visit('/form') }

  it "should be false if a checked field is on the page" do
    @session.should_not have_no_checked_field('gender_female')
    @session.should_not have_no_checked_field('Hamster')
  end

  it "should be true if an unchecked field is on the page" do
    @session.should have_no_checked_field('form_pets_cat')
    @session.should have_no_checked_field('Male')
  end

  it "should be true if no field is on the page" do
    @session.should have_no_checked_field('Does Not Exist')
  end
end

Capybara::SpecHelper.spec '#has_unchecked_field?' do
  before { @session.visit('/form') }

  it "should be false if a checked field is on the page" do
    @session.should_not have_unchecked_field('gender_female')
    @session.should_not have_unchecked_field('Hamster')
  end

  it "should be true if an unchecked field is on the page" do
    @session.should have_unchecked_field('form_pets_cat')
    @session.should have_unchecked_field('Male')
  end

  it "should be false if no field is on the page" do
    @session.should_not have_unchecked_field('Does Not Exist')
  end

  it "should be false after an unchecked checkbox is checked" do
    @session.check('form_pets_cat')
    @session.should_not have_unchecked_field('form_pets_cat')
  end

  it "should be true after a checked checkbox is unchecked" do
    @session.uncheck('form_pets_dog')
    @session.should have_unchecked_field('form_pets_dog')
  end

  it "should be false after an unchecked radio button is chosen" do
    @session.choose('gender_male')
    @session.should_not have_unchecked_field('gender_male')
  end

  it "should be true after another radio button in the group is chosen" do
    @session.choose('gender_male')
    @session.should have_unchecked_field('gender_female')
  end
end

Capybara::SpecHelper.spec '#has_no_unchecked_field?' do
  before { @session.visit('/form') }

  it "should be true if a checked field is on the page" do
    @session.should have_no_unchecked_field('gender_female')
    @session.should have_no_unchecked_field('Hamster')
  end

  it "should be false if an unchecked field is on the page" do
    @session.should_not have_no_unchecked_field('form_pets_cat')
    @session.should_not have_no_unchecked_field('Male')
  end

  it "should be true if no field is on the page" do
    @session.should have_no_unchecked_field('Does Not Exist')
  end
end
