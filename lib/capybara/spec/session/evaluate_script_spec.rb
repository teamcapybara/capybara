Capybara::SpecHelper.spec "#evaluate_script", :requires => [:js] do
  it "should evaluate the given script and return whatever it produces" do
    @session.visit('/with_js')
    @session.evaluate_script("1+3").should == 4
  end

  it "should support arguments" do
    @session.visit('/with_js')
    @session.evaluate_script("arguments[0] + arguments[1]", 1, 3).should == 4
  end

  it "should support Capybara::Node::Element arguments" do
    @session.visit('/with_js')
    element = @session.find("//p[@id='eval_p']")
    @session.evaluate_script("$(arguments[0]).text()", element).should == "Some text"
  end

  it "should cast returned native arguments to Capybara::Node::Element or Capybara::Driver::Node" do
    @session.visit('/with_js')
    elem = @session.evaluate_script("$(arguments[0])[0]", '#eval_input')
    correct_class = elem.is_a?(Capybara::Driver::Node) || elem.class == Capybara::Node::Element
    correct_class.should == true
    elem.set("New text")
    @session.find("//input[@id='eval_input']").value.should == "New text"
  end
end
