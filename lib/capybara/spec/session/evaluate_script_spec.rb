Capybara::SpecHelper.spec "#evaluate_script", :requires => [:js] do
  it "should evaluate the given script and return whatever it produces" do
    @session.visit('/with_js')
    expect(@session.evaluate_script("1+3")).to eq(4)
  end
  it "should return text from dom element using string id" do
    @session.visit('/javascript_evaluate')
    expect(@session.evaluate_script('document.getElementById("test").innerHTML')).to eq('This is a sample text')
  end

  it "should return text from dom element passing selenium element to the expression" do
    @session.visit('/javascript_evaluate')
    el = @session.find(:css, '#test')
    expect(@session.evaluate_script('arguments[0].innerHTML', el)).to eq('This is a sample text')
  end
end
