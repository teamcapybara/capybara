Capybara::SpecHelper.spec '#title' do

  it "should print the title of the page" do
    @session.visit('/with_title')
    @session.title.should == 'Test Title'
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should print the title of the page" do
      @session.visit('/with_title')
      @session.title.should == 'Test Title'
    end
    after { Capybara.default_selector = :xpath }
  end
end