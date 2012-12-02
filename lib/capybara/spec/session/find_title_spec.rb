Capybara::SpecHelper.spec '#find_title' do
  before do
    @session.visit('/with_js')
  end

  it "should find any field" do
    @session.find_title('with_js').tag_name.should == "title"
  end

  it "casts to string" do
    @session.find_title(:'with_js').tag_name.should == "title"
  end

  it "should raise error if the title doesn't exist" do
    expect do
      @session.find_title('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end
end
