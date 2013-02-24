Capybara::SpecHelper.spec '#click_link' do
  before do
    @session.visit('/with_html')
  end

  it "should wait for asynchronous load", :requires => [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    @session.click_link('Has been clicked')
  end

  it "casts to string" do
    @session.click_link(:'foo')
    @session.should have_content('Another World')
  end

  context "with id given" do
    it "should take user to the linked page" do
      @session.click_link('foo')
      @session.should have_content('Another World')
    end
  end

  context "with text given" do
    it "should take user to the linked page" do
      @session.click_link('labore')
      @session.should have_content('Bar')
    end

    it "should accept partial matches" do
      @session.click_link('abo')
      @session.should have_content('Bar')
    end
  end

  context "with title given" do
    it "should take user to the linked page" do
      @session.click_link('awesome title')
      @session.should have_content('Bar')
    end

    it "should accept partial matches" do
      @session.click_link('some titl')
      @session.should have_content('Bar')
    end
  end

  context "with alternative text given to a contained image" do
    it "should take user to the linked page" do
      @session.click_link('awesome image')
      @session.should have_content('Bar')
    end

    it "should accept partial matches" do
      @session.click_link('some imag')
      @session.should have_content('Bar')
    end
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find link \"does not exist\""
      expect do
        @session.click_link('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with :href option given" do
    it "should find links with valid href" do
      @session.click_link('labore', :href => '/with_simple_html')
      @session.should have_content('Bar')
    end

    it "should raise error if link wasn't found" do
      expect { @session.click_link('labore', :href => 'invalid_href') }.to raise_error(Capybara::ElementNotFound)
    end
  end

  it "should follow relative links" do
    @session.visit('/')
    @session.click_link('Relative')
    @session.should have_content('This is a test')
  end

  it "should follow protocol relative links" do
    @session.click_link('Protocol')
    @session.should have_content('Another World')
  end

  it "should follow redirects" do
    @session.click_link('Redirect')
    @session.should have_content('You landed')
  end

  it "should follow redirects" do
    @session.click_link('BackToMyself')
    @session.should have_content('This is a test')
  end

  it "should add query string to current URL with naked query string" do
    @session.click_link('Naked Query String')
    @session.should have_content('Query String sent')
  end

  it "should do nothing on anchor links" do
    @session.fill_in("test_field", :with => 'blah')
    @session.click_link('Normal Anchor')
    @session.find_field("test_field").value.should == 'blah'
    @session.click_link('Blank Anchor')
    @session.find_field("test_field").value.should == 'blah'
  end

  it "should do nothing on URL+anchor links for the same page" do
    @session.fill_in("test_field", :with => 'blah')
    @session.click_link('Anchor on same page')
    @session.find_field("test_field").value.should == 'blah'
  end

  it "should follow link on URL+anchor links for a different page" do
    @session.click_link('Anchor on different page')
    @session.should have_content('Bar')
  end

  it "raise an error with links with no href" do
    expect do
      @session.click_link('No Href')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.click_link('abo', :exact => false)
      @session.should have_content('Bar')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.click_link('abo', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
