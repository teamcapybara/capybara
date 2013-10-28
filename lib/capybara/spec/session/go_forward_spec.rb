Capybara::SpecHelper.spec '#go_forward', :requires => [:js] do
  it "should fetch a response from the driver from the previous page" do
    @session.visit('/')
    @session.should have_content('Hello world!')
    @session.visit('/foo')
    @session.should have_content('Another World')
    @session.go_back
    @session.should have_content('Hello world!')
    @session.go_forward
    @session.should have_content('Another World')
  end
end
