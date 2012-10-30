Capybara::SpecHelper.spec '#find_by_id' do
  before do
    @session.visit('/with_html')
  end

  it "should find any element by id" do
    @session.find_by_id('red').tag_name.should == 'a'
    @session.find_by_id('hidden_via_ancestor').tag_name.should == 'div'
  end

  it "casts to string" do
    @session.find_by_id(:'red').tag_name.should == 'a'
  end

  it "should raise error if no element with id is found" do
    expect do
      @session.find_by_id('nothing_with_this_id')
    end.to raise_error(Capybara::ElementNotFound)
  end
end
