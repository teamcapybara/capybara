shared_examples_for "find_link" do

  describe '#find_link' do
    before do
      @session.visit('/with_html')
    end

    it "should find any field" do
      @session.find_link('foo').text.should == "ullamco"
      @session.find_link('labore')[:href].should =~ %r(/with_simple_html$)
    end

    it "should raise error if the field doesn't exist" do
      running do
        @session.find_link('Does not exist')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
