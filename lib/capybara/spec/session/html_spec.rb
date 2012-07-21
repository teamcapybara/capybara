Capybara::SpecHelper.spec '#html' do
  it "should return the unmodified page body" do
    # html and body should be aliased, but we can't just check for
    # method(:html) == method(:body) because these shared examples get run
    # against the DSL, which uses forwarding methods.  So we test behavior.
    @session.visit('/')
    @session.html.should include('Hello world!')
  end

  it "should return the current state of the page", :requires => [:js] do
    @session.visit('/with_js')
    @session.html.should include('I changed it')
    @session.html.should_not include('This is text')
  end
end
