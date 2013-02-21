Capybara::SpecHelper.spec '#window' do
  it "gets the window size", requires: [:live] do
    @session.visit('/with_html')
    @session.window.size.should == @session.execute_script("return [window.outerWidth, window.outerHeight];")
  end
  
  it "resizes the window", requires: [:live] do
    @session.visit('/with_html')
    width, height = @session.execute_script("return [window.outerWidth, window.outerHeight];")
    @session.window.resize(width-10, height-10)
    @session.execute_script("return [window.outerWidth, window.outerHeight];").should == [width-10, height-10]
  end
end
