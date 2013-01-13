Capybara::SpecHelper.spec "#execute_script", :requires => [:js] do
  it "should execute the given script and return nothing" do
    @session.visit('/with_js')
    @session.execute_script("$('#change').text('Funky Doodle')").should be_nil
    @session.should have_css('#change', :text => 'Funky Doodle')
  end

  it "should support arguments" do
    @session.visit('/with_js')
    @session.execute_script("$(arguments[0]).text(arguments[1])", '#change', 'Funky Doodle').should be_nil
    @session.should have_css('#change', :text => 'Funky Doodle')
  end
end
