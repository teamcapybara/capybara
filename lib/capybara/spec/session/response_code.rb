Capybara::SpecHelper.spec '#status_code' do
  it "should return response codes", :requires => [:status_code] do
    @session.visit('/with_simple_html')
    @session.status_code.should == 200
  end
end
