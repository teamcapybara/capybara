Capybara::SpecHelper.spec '#source' do
  it "should return the unmodified page source" do
    @session.visit('/')
    @session.source.should include('Hello world!')
  end

  it "should return the original, unmodified source of the page", :requires => [:js, :source] do
    @session.visit('/with_js')
    @session.send(method).should include('This is text')
    @session.send(method).should_not include('I changed it')
  end
end
