shared_examples_for "find_button" do  
  describe '#find_button' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_button('med')[:id].should == "mediocre"
      @session.find_button('crap321').value.should == "crappy"
    end

    it "should raise error if the field doesn't exist" do
      running do
        @session.find_button('Does not exist')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
