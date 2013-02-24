Capybara::SpecHelper.spec '#find_button' do
  before do
    @session.visit('/form')
  end

  it "should find any button" do
    @session.find_button('med')[:id].should == "mediocre"
    @session.find_button('crap321').value.should == "crappy"
  end

  it "casts to string" do
    @session.find_button(:'med')[:id].should == "mediocre"
  end

  it "should raise error if the button doesn't exist" do
    expect do
      @session.find_button('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.find_button('What an Awesome', :exact => false)[:value].should == "awesome"
    end

    it "should not accept partial matches when true" do
      expect do
        @session.find_button('What an Awesome', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
