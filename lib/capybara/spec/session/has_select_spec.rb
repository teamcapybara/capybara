Capybara::SpecHelper.spec '#has_select?' do
  before { @session.visit('/form') }

  it "should be true if the field is on the page" do
    expect(@session).to have_select('Locale')
    expect(@session).to have_select('form_region')
    expect(@session).to have_select('Languages')
    expect(@session).to have_select(:'Languages')
  end

  it "should be false if the field is not on the page" do
    expect(@session).not_to have_select('Monkey')
  end

  context 'with selected value' do
    it "should be true if a field with the given value is on the page" do
      expect(@session).to have_select('form_locale', :selected => 'English')
      expect(@session).to have_select('Region', :selected => 'Norway')
      expect(@session).to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be false if the given field is not on the page" do
      expect(@session).not_to have_select('Locale', :selected => 'Swedish')
      expect(@session).not_to have_select('Does not exist', :selected => 'John')
      expect(@session).not_to have_select('City', :selected => 'Not there')
      expect(@session).not_to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns', 'Nonexistant'
      ])
      expect(@session).not_to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
      expect(@session).not_to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs','Commando', "Frenchman's Pantalons"
      ])
    end

    it "should be true after the given value is selected" do
      @session.select('Swedish', :from => 'Locale')
      expect(@session).to have_select('Locale', :selected => 'Swedish')
    end

    it "should be false after a different value is selected" do
      @session.select('Swedish', :from => 'Locale')
      expect(@session).not_to have_select('Locale', :selected => 'English')
    end

    it "should be true after the given values are selected" do
      @session.select('Boxers', :from => 'Underwear')
      expect(@session).to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be false after one of the values is unselected" do
      @session.unselect('Briefs', :from => 'Underwear')
      expect(@session).not_to have_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be true even when the selected option invisible, regardless of the select's visibility" do
      expect(@session).to have_select('Icecream', :visible => false, :selected => 'Chocolate')
      expect(@session).to have_select('Sorbet', :selected => 'Vanilla')
    end
  end

  context 'with exact options' do
    it "should be true if a field with the given options is on the page" do
      expect(@session).to have_select('Region', :options => ['Norway', 'Sweden', 'Finland'])
      expect(@session).to have_select('Tendency', :options => [])
    end

    it "should be false if the given field is not on the page" do
      expect(@session).not_to have_select('Locale', :options => ['Swedish'])
      expect(@session).not_to have_select('Does not exist', :options => ['John'])
      expect(@session).not_to have_select('City', :options => ['London', 'Made up city'])
      expect(@session).not_to have_select('Region', :options => ['Norway', 'Sweden'])
      expect(@session).not_to have_select('Region', :options => ['Norway', 'Norway', 'Norway'])
    end

    it" should be true even when the options are invisible, if the select itself is invisible" do
      expect(@session).to have_select("Icecream", :visible => false, :options => ['Chocolate', 'Vanilla', 'Strawberry'])
    end

  end

  context 'with partial options' do
    it "should be true if a field with the given partial options is on the page" do
      expect(@session).to have_select('Region', :with_options => ['Norway', 'Sweden'])
      expect(@session).to have_select('City', :with_options => ['London'])
    end

    it "should be false if a field with the given partial options is not on the page" do
      expect(@session).not_to have_select('Locale', :with_options => ['Uruguayan'])
      expect(@session).not_to have_select('Does not exist', :with_options => ['John'])
      expect(@session).not_to have_select('Region', :with_options => ['Norway', 'Sweden', 'Finland', 'Latvia'])
    end

    it" should be true even when the options are invisible, if the select itself is invisible" do
      expect(@session).to have_select("Icecream", :visible => false, :with_options => ['Vanilla', 'Strawberry'])
    end
  end
end

Capybara::SpecHelper.spec '#has_no_select?' do
  before { @session.visit('/form') }

  it "should be false if the field is on the page" do
    expect(@session).not_to have_no_select('Locale')
    expect(@session).not_to have_no_select('form_region')
    expect(@session).not_to have_no_select('Languages')
  end

  it "should be true if the field is not on the page" do
    expect(@session).to have_no_select('Monkey')
  end

  context 'with selected value' do
    it "should be false if a field with the given value is on the page" do
      expect(@session).not_to have_no_select('form_locale', :selected => 'English')
      expect(@session).not_to have_no_select('Region', :selected => 'Norway')
      expect(@session).not_to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be true if the given field is not on the page" do
      expect(@session).to have_no_select('Locale', :selected => 'Swedish')
      expect(@session).to have_no_select('Does not exist', :selected => 'John')
      expect(@session).to have_no_select('City', :selected => 'Not there')
      expect(@session).to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns', 'Nonexistant'
      ])
      expect(@session).to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
      expect(@session).to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs','Commando', "Frenchman's Pantalons"
      ])
    end

    it "should be false after the given value is selected" do
      @session.select('Swedish', :from => 'Locale')
      expect(@session).not_to have_no_select('Locale', :selected => 'Swedish')
    end

    it "should be true after a different value is selected" do
      @session.select('Swedish', :from => 'Locale')
      expect(@session).to have_no_select('Locale', :selected => 'English')
    end

    it "should be false after the given values are selected" do
      @session.select('Boxers', :from => 'Underwear')
      expect(@session).not_to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Boxers', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end

    it "should be true after one of the values is unselected" do
      @session.unselect('Briefs', :from => 'Underwear')
      expect(@session).to have_no_select('Underwear', :selected => [
        'Boxerbriefs', 'Briefs', 'Commando', "Frenchman's Pantalons", 'Long Johns'
      ])
    end
  end

  context 'with exact options' do
    it "should be false if a field with the given options is on the page" do
      expect(@session).not_to have_no_select('Region', :options => ['Norway', 'Sweden', 'Finland'])
    end

    it "should be true if the given field is not on the page" do
      expect(@session).to have_no_select('Locale', :options => ['Swedish'])
      expect(@session).to have_no_select('Does not exist', :options => ['John'])
      expect(@session).to have_no_select('City', :options => ['London', 'Made up city'])
      expect(@session).to have_no_select('Region', :options => ['Norway', 'Sweden'])
      expect(@session).to have_no_select('Region', :options => ['Norway', 'Norway', 'Norway'])
    end
  end

  context 'with partial options' do
    it "should be false if a field with the given partial options is on the page" do
      expect(@session).not_to have_no_select('Region', :with_options => ['Norway', 'Sweden'])
      expect(@session).not_to have_no_select('City', :with_options => ['London'])
    end

    it "should be true if a field with the given partial options is not on the page" do
      expect(@session).to have_no_select('Locale', :with_options => ['Uruguayan'])
      expect(@session).to have_no_select('Does not exist', :with_options => ['John'])
      expect(@session).to have_no_select('Region', :with_options => ['Norway', 'Sweden', 'Finland', 'Latvia'])
    end
  end
end
