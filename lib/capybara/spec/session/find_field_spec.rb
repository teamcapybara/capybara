shared_examples_for "find_field" do  
  describe '#find_field' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_field('Dog').value.should == 'dog'
      @session.find_field('form_description').text.should == 'Descriptive text goes here'
      @session.find_field('Region')[:name].should == 'form[region]'
    end

    it "should raise error if the field doesn't exist" do
      running do
        @session.find_field('Does not exist')
      end.should raise_error(Capybara::ElementNotFound)
    end

    it "should be aliased as 'field_labeled' for webrat compatibility" do
      @session.field_labeled('Dog').value.should == 'dog'
      running do
        @session.field_labeled('Does not exist')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
