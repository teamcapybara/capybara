Capybara::SpecHelper.spec "#evaluate_script", :requires => [:js] do
  it "should evaluate the given script and return whatever it produces" do
    @session.visit('/with_js')
    expect(@session.evaluate_script("1+3")).to eq(4)
  end
end
