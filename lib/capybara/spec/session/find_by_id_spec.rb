Capybara::SpecHelper.spec '#find_by_id' do
  before do
    @session.visit('/with_html')
  end

  it "should find any element by id" do
    @session.find_by_id('red').tag_name.should == 'a'
  end

  it "casts to string" do
    @session.find_by_id(:'red').tag_name.should == 'a'
  end

  it "should raise error if no element with id is found" do
    expect do
      @session.find_by_id('nothing_with_this_id')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :visible option" do
    it "finds invisible elements when `false`" do
      @session.find_by_id("hidden_via_ancestor", :visible => false).text(:all).should =~ /with hidden ancestor/
    end

    it "finds invisible elements when `false`" do
      expect do
        @session.find_by_id("hidden_via_ancestor", :visible => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
