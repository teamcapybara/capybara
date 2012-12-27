Capybara::SpecHelper.spec "#evaluate_script", :requires => [:js] do
  it "should evaluate the given script and return whatever it produces" do
    @session.visit('/with_js')
    @session.evaluate_script("1+3").should == 4
  end
end
