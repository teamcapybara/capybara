Capybara::SpecHelper.spec '#has_select?' do
  before { @session.visit('/form') }

  it "should be true if the field is on the page" do
    @session.should have_select('Locale')
    @session.should have_select('form_region')
    @session.should have_select('Languages')
    @session.should have_select(:'Languages')
  end

  it "should be false if the field is not on the page" do
    @session.should_not have_select('Monkey')
  end

  context 'with selected value' do
    it "should be true if a field with the given value is on the page" do
      @session.should have_select('form_locale', :selected => 'English')
      @session.should have_select('Region', :selected => 'Norway')
      @session.should have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be false if the given field is not on the page" do
      @session.should_not have_select('Locale', :selected => 'Swedish')
      @session.should_not have_select('Does not exist', :selected => 'John')
      @session.should_not have_select('City', :selected => 'Not there')
      @session.should_not have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns', 'Nonexistant'
      ])
      @session.should_not have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
      @session.should_not have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs','Commando', "Frenchman's Pantalons"
      ])
    end

    it "should be true after the given value is selected" do
      @session.select('Swedish', :from => 'Locale')
      @session.should have_select('Locale', :selected => 'Swedish')
    end

    it "should be false after a different value is selected" do
      @session.select('Swedish', :from => 'Locale')
      @session.should_not have_select('Locale', :selected => 'English')
    end

    it "should be true after the given values are selected" do
      @session.select('Boxers', :from => 'Underwear')
      @session.should have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be false after one of the values is unselected" do
      @session.unselect('Briefs', :from => 'Underwear')
      @session.should_not have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end
  end

  context 'with exact options' do
    it "should be true if a field with the given options is on the page" do
      @session.should have_select('Region', :options => ['Norway', 'Sweden', 'Finland'])
      @session.should have_select('Tendency', :options => [])
    end

    it "should be false if the given field is not on the page" do
      @session.should_not have_select('Locale', :options => ['Swedish'])
      @session.should_not have_select('Does not exist', :options => ['John'])
      @session.should_not have_select('City', :options => ['London', 'Made up city'])
      @session.should_not have_select('Region', :options => ['Norway', 'Sweden'])
      @session.should_not have_select('Region', :options => ['Norway', 'Norway', 'Norway'])
    end
  end

  context 'with partial options' do
    it "should be true if a field with the given partial options is on the page" do
      @session.should have_select('Region', :with_options => ['Norway', 'Sweden'])
      @session.should have_select('City', :with_options => ['London'])
    end

    it "should be false if a field with the given partial options is not on the page" do
      @session.should_not have_select('Locale', :with_options => ['Uruguayan'])
      @session.should_not have_select('Does not exist', :with_options => ['John'])
      @session.should_not have_select('Region', :with_options => ['Norway', 'Sweden', 'Finland', 'Latvia'])
    end
  end
end

Capybara::SpecHelper.spec '#has_no_select?' do
  before { @session.visit('/form') }

  it "should be false if the field is on the page" do
    @session.should_not have_no_select('Locale')
    @session.should_not have_no_select('form_region')
    @session.should_not have_no_select('Languages')
  end

  it "should be true if the field is not on the page" do
    @session.should have_no_select('Monkey')
  end

  context 'with selected value' do
    it "should be false if a field with the given value is on the page" do
      @session.should_not have_no_select('form_locale', :selected => 'English')
      @session.should_not have_no_select('Region', :selected => 'Norway')
      @session.should_not have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be true if the given field is not on the page" do
      @session.should have_no_select('Locale', :selected => 'Swedish')
      @session.should have_no_select('Does not exist', :selected => 'John')
      @session.should have_no_select('City', :selected => 'Not there')
      @session.should have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns', 'Nonexistant'
      ])
      @session.should have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
      @session.should have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs','Commando', "Frenchman's Pantalons"
      ])
    end

    it "should be false after the given value is selected" do
      @session.select('Swedish', :from => 'Locale')
      @session.should_not have_no_select('Locale', :selected => 'Swedish')
    end

    it "should be true after a different value is selected" do
      @session.select('Swedish', :from => 'Locale')
      @session.should have_no_select('Locale', :selected => 'English')
    end

    it "should be false after the given values are selected" do
      @session.select('Boxers', :from => 'Underwear')
      @session.should_not have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be true after one of the values is unselected" do
      @session.unselect('Briefs', :from => 'Underwear')
      @session.should have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end
  end

  context 'with exact options' do
    it "should be false if a field with the given options is on the page" do
      @session.should_not have_no_select('Region', :options => ['Norway', 'Sweden', 'Finland'])
    end

    it "should be true if the given field is not on the page" do
      @session.should have_no_select('Locale', :options => ['Swedish'])
      @session.should have_no_select('Does not exist', :options => ['John'])
      @session.should have_no_select('City', :options => ['London', 'Made up city'])
      @session.should have_no_select('Region', :options => ['Norway', 'Sweden'])
      @session.should have_no_select('Region', :options => ['Norway', 'Norway', 'Norway'])
    end
  end

  context 'with partial options' do
    it "should be false if a field with the given partial options is on the page" do
      @session.should_not have_no_select('Region', :with_options => ['Norway', 'Sweden'])
      @session.should_not have_no_select('City', :with_options => ['London'])
    end

    it "should be true if a field with the given partial options is not on the page" do
      @session.should have_no_select('Locale', :with_options => ['Uruguayan'])
      @session.should have_no_select('Does not exist', :with_options => ['John'])
      @session.should have_no_select('Region', :with_options => ['Norway', 'Sweden', 'Finland', 'Latvia'])
    end
  end
end
