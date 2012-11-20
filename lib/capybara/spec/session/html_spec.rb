Capybara::SpecHelper.spec '#html' do
  it "should return the unmodified page body" do
    @session.visit('/')
    @session.html.should include('Hello world!')
  end

  it "should return the current state of the page", :requires => [:js] do
    @session.visit('/with_js')
    @session.html.should include('I changed it')
    @session.html.should_not include('This is text')
  end
end

Capybara::SpecHelper.spec '#source' do
  it "should return the unmodified page source" do
    @session.visit('/')
    @session.source.should include('Hello world!')
  end

  it "should return the current state of the page", :requires => [:js] do
    @session.visit('/with_js')
    @session.source.should include('I changed it')
    @session.source.should_not include('This is text')
  end
end

Capybara::SpecHelper.spec '#body' do
  it "should return the unmodified page source" do
    @session.visit('/')
    @session.body.should include('Hello world!')
  end

  it "should return the current state of the page", :requires => [:js] do
    @session.visit('/with_js')
    @session.body.should include('I changed it')
    @session.body.should_not include('This is text')
  end
end
