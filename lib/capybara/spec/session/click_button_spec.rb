Capybara::SpecHelper.spec '#click_button' do
  before do
    @session.visit('/form')
  end

  it "should wait for asynchronous load", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.click_button('New Here')
  end

  it "casts to string" do
    @session.click_button(:'Relative Action')
    @session.current_path.should == '/relative'
    extract_results(@session)['relative'].should == 'Relative Action'
  end

  context "with multiple values with the same name" do
    it "should use the latest given value" do
      @session.check('Terms of Use')
      @session.click_button('awesome')
      extract_results(@session)['terms_of_use'].should == '1'
    end
  end

  context "with a form that has a relative url as an action" do
    it "should post to the correct url" do
      @session.click_button('Relative Action')
      @session.current_path.should == '/relative'
      extract_results(@session)['relative'].should == 'Relative Action'
    end
  end

  context "with a form that has no action specified" do
    it "should post to the correct url" do
      @session.click_button('No Action')
      @session.current_path.should == '/form'
      extract_results(@session)['no_action'].should == 'No Action'
    end
  end

  context "with value given on a submit button" do
    context "on a form with HTML5 fields" do
      before do
        @session.click_button('html5_submit')
        @results = extract_results(@session)
      end

      it "should serialise and submit search fields" do
        @results['html5_search'].should == 'what are you looking for'
      end

      it "should serialise and submit email fields" do
        @results['html5_email'].should == 'person@email.com'
      end

      it "should serialise and submit url fields" do
        @results['html5_url'].should == 'http://www.example.com'
      end

      it "should serialise and submit tel fields" do
        @results['html5_tel'].should == '911'
      end

      it "should serialise and submit color fields" do
        @results['html5_color'].upcase.should == '#FFFFFF'
      end
    end

    context "on an HTML4 form" do
      before do
        @session.click_button('awesome')
        @results = extract_results(@session)
      end

      it "should serialize and submit text fields" do
        @results['first_name'].should == 'John'
      end

      it "should escape fields when submitting" do
        @results['phone'].should == '+1 555 7021'
      end

      it "should serialize and submit password fields" do
        @results['password'].should == 'seeekrit'
      end

      it "should serialize and submit hidden fields" do
        @results['token'].should == '12345'
      end

      it "should not serialize fields from other forms" do
        @results['middle_name'].should be_nil
      end

      it "should submit the button that was clicked, but not other buttons" do
        @results['awesome'].should == 'awesome'
        @results['crappy'].should be_nil
      end

      it "should serialize radio buttons" do
        @results['gender'].should == 'female'
      end

      it "should serialize check boxes" do
        @results['pets'].should include('dog', 'hamster')
        @results['pets'].should_not include('cat')
      end

      it "should serialize text areas" do
        @results['description'].should == 'Descriptive text goes here'
      end

      it "should serialize select tag with values" do
        @results['locale'].should == 'en'
      end

      it "should serialize select tag without values" do
        @results['region'].should == 'Norway'
      end

      it "should serialize first option for select tag with no selection" do
        @results['city'].should == 'London'
      end

      it "should not serialize a select tag without options" do
        @results['tendency'].should be_nil
      end

      it "should not submit disabled fields" do
        @results['disabled_text_field'].should be_nil
        @results['disabled_textarea'].should be_nil
        @results['disabled_checkbox'].should be_nil
        @results['disabled_radio'].should be_nil
        @results['disabled_select'].should be_nil
        @results['disabled_file'].should be_nil
      end
    end
  end

  context "with id given on a submit button" do
    it "should submit the associated form" do
      @session.click_button('awe123')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('Go')
      @session.should have_content('You landed')
    end
  end

  context "with title given on a submit button" do
    it "should submit the associated form" do
      @session.click_button('What an Awesome Button')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('What an Awesome')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with fields associated with the form using the form attribute" do
    before do
      @session.click_button('submit_form1')
      @results = extract_results(@session)
    end

    it "should serialize and submit text fields" do
      @results['outside_input'].should == 'outside_input'
    end

    it "should serialize text areas" do
      @results['outside_textarea'].should == 'Some text here'
    end

    it "should serialize select tags" do
      @results['outside_select'].should == 'Ruby'
    end

    it "should not serliaze fields associated with a different form" do
      @results['for_form2'].should be_nil
    end
  end


  context "with submit button outside the form defined by <button> tag" do
    before do
      @session.click_button('outside_button')
      @results = extract_results(@session)
    end

    it "should submit the associated form" do
      @results['which_form'].should == 'form2'
    end

    it "should submit the button that was clicked, but not other buttons" do
      @results['outside_button'].should == 'outside_button'
      @results['unused'].should be_nil
    end
  end

  context "with submit button outside the form defined by <input type='submit'> tag" do
    before do
      @session.click_button('outside_submit')
      @results = extract_results(@session)
    end

    it "should submit the associated form" do
      @results['which_form'].should == 'form1'
    end

    it "should submit the button that was clicked, but not other buttons" do
      @results['outside_submit'].should == 'outside_submit'
      @results['submit_form1'].should be_nil
    end
  end

  context "with submit button for form1 located within form2" do
    it "should submit the form associated with the button" do
      @session.click_button('other_form_button')
      extract_results(@session)['which_form'].should == "form1"
    end
  end

  context "with alt given on an image button" do
    it "should submit the associated form" do
      @session.click_button('oh hai thar')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('hai')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with value given on an image button" do
    it "should submit the associated form" do
      @session.click_button('okay')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('kay')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with id given on an image button" do
    it "should submit the associated form" do
      @session.click_button('okay556')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with title given on an image button" do
    it "should submit the associated form" do
      @session.click_button('Okay 556 Image')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('Okay 556')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with text given on a button defined by <button> tag" do
    it "should submit the associated form" do
      @session.click_button('Click me')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('Click')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

 context "with id given on a button defined by <button> tag" do
    it "should submit the associated form" do
      @session.click_button('click_me_123')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should serialize and send GET forms" do
      @session.visit('/form')
      @session.click_button('med')
      @results = extract_results(@session)
      @results['middle_name'].should == 'Darren'
      @results['foo'].should be_nil
    end
  end

 context "with value given on a button defined by <button> tag" do
    it "should submit the associated form" do
      @session.click_button('click_me')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('ck_me')
      extract_results(@session)['first_name'].should == 'John'
    end
  end

  context "with title given on a button defined by <button> tag" do
    it "should submit the associated form" do
      @session.click_button('Click Title button')
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should work with partial matches" do
      @session.click_button('Click Title')
      extract_results(@session)['first_name'].should == 'John'
    end
  end
  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find button \"does not exist\""
      expect do
        @session.click_button('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  it "should serialize and send valueless buttons that were clicked" do
    @session.click_button('No Value!')
    @results = extract_results(@session)
    @results['no_value'].should_not be_nil
  end

  it "should not send image buttons that were not clicked" do
    @session.click_button('Click me!')
    @results = extract_results(@session)
    @results['okay'].should be_nil
  end

  it "should serialize and send GET forms" do
    @session.visit('/form')
    @session.click_button('med')
    @results = extract_results(@session)
    @results['middle_name'].should == 'Darren'
    @results['foo'].should be_nil
  end

  it "should follow redirects" do
    @session.click_button('Go FAR')
    @session.current_url.should match(%r{/landed$})
    @session.should have_content('You landed')
  end

  it "should post pack to the same URL when no action given" do
    @session.visit('/postback')
    @session.click_button('With no action')
    @session.should have_content('Postback')
  end

  it "should post pack to the same URL when blank action given" do
    @session.visit('/postback')
    @session.click_button('With blank action')
    @session.should have_content('Postback')
  end

  it "ignores disabled buttons" do
    expect do
      @session.click_button('Disabled button')
    end.to raise_error(Capybara::ElementNotFound)
  end

  it "should encode complex field names, like array[][value]" do
    @session.visit('/form')
    @session.fill_in('address1_city', :with =>'Paris')
    @session.fill_in('address1_street', :with =>'CDG')
    @session.fill_in('address1_street', :with =>'CDG')
    @session.select("France", :from => 'address1_country')

    @session.fill_in('address2_city', :with => 'Mikolaiv')
    @session.fill_in('address2_street', :with => 'PGS')
    @session.select("Ukraine", :from => 'address2_country')

    @session.click_button "awesome"

    addresses=extract_results(@session)["addresses"]
    addresses.should have(2).addresses

    addresses[0]["street"].should   == 'CDG'
    addresses[0]["city"].should     == 'Paris'
    addresses[0]["country"].should  == 'France'

    addresses[1]["street"].should   == 'PGS'
    addresses[1]["city"].should     == 'Mikolaiv'
    addresses[1]["country"].should  == 'Ukraine'
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.click_button('What an Awesome', :exact => false)
      extract_results(@session)['first_name'].should == 'John'
    end

    it "should not accept partial matches when true" do
      expect do
        @session.click_button('What an Awesome', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
