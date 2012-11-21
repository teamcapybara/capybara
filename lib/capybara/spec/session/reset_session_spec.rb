Capybara::SpecHelper.spec '#reset_session!' do
  it "removes cookies" do
    @session.visit('/set_cookie')
    @session.visit('/get_cookie')
    @session.should have_content('test_cookie')

    @session.reset_session!
    @session.visit('/get_cookie')
    @session.html.should_not include('test_cookie')
  end

  it "resets current url, host, path" do
    @session.visit '/foo'
    @session.current_url.should_not be_empty
    @session.current_host.should_not be_empty
    @session.current_path.should == '/foo'

    @session.reset_session!
    [nil, '', 'about:blank'].should include @session.current_url
    @session.current_host.should be_nil
    @session.current_path.should be_nil
  end

  it "resets page body" do
    @session.visit('/with_html')
    @session.should have_content('This is a test')
    @session.find('.//h1').text.should include('This is a test')

    @session.reset_session!
    @session.html.should_not include('This is a test')
    @session.should have_no_selector('.//h1')
  end

  it "raises any errors caught inside the server" do
    expect do
      quietly { @session.visit("/error") }
      @session.reset_session!
    end.to raise_error(TestApp::TestAppError)
    @session.visit("/")
    @session.current_path.should == "/"
  end
end
