shared_examples_for "find_by_id" do  
  describe '#find_by_id' do
    before do
      @session.visit('/with_html')
    end

    it "should find any element by id" do
      @session.find_by_id('red').tag_name.should == 'a'
      @session.find_by_id('hidden_via_ancestor').tag_name.should == 'div'
    end

    it "should raise error if no element with id is found" do
      running do
        @session.find_by_id('nothing_with_this_id')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
