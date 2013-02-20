Capybara::SpecHelper.spec '#resize_window' do
  it "resizes the window", requires: [:live] do
    @session.visit('/with_html')
    width, height = @session.execute_script("return [window.outerWidth, window.outerHeight];")
    @session.resize_window(width-10, height-10)
    @session.execute_script("return [window.outerWidth, window.outerHeight];").should == [width-10, height-10]
  end
end
