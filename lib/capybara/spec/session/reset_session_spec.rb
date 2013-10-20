Capybara::SpecHelper.spec '#reset_session!' do
  it "removes cookies" do
    @session.visit('/set_cookie')
    @session.visit('/get_cookie')
    @session.should have_content('test_cookie')

    @session.reset_session!
    @session.visit('/get_cookie')
    @session.body.should_not include('test_cookie')
  end

  it "resets current url, host, path" do
    @session.visit '/foo'
    @session.current_url.should_not be_empty
    @session.current_host.should_not be_empty
    @session.current_path.should == '/foo'

    @session.reset_session!
    [
      ->(v) { v == nil },
      ->(v) { v == '' },
      ->(v) { v == 'about:blank' },
      ->(v) { v.end_with? Capybara::EMPTY_HTML_FILE_PATH } # allow file:// protocol
    ].any? { |p| p.(@session.current_url) }.should be_true
    [
      ->(v) { v == '' },
      ->(v) { v == nil },
      ->(v) { v == Capybara::EMPTY_HTML_FILE_PATH }
    ].any? { |p| p.(@session.current_path) }.should be_true
    @session.current_host.should be_nil
  end

  it "resets page body" do
    @session.visit('/with_html')
    @session.should have_content('This is a test')
    @session.find('.//h1').text.should include('This is a test')

    @session.reset_session!
    @session.body.should_not include('This is a test')
    @session.should have_no_selector('.//h1')
  end

  it "is synchronous" do
    @session.visit("/with_html")
    @session.reset_session!
    @session.should have_no_selector :xpath, "/html/body/*", wait: false
  end

  it "raises any errors caught inside the server", :requires => [:server] do
    quietly { @session.visit("/error") }
    expect do
      @session.reset_session!
    end.to raise_error(TestApp::TestAppError)
    @session.visit("/")
    @session.current_path.should == "/"
  end

  it "ignores server errors when `Capybara.raise_server_errors = false`", :requires => [:server] do
    Capybara.raise_server_errors = false
    quietly { @session.visit("/error") }
    @session.reset_session!
    @session.visit("/")
    @session.current_path.should == "/"
  end
end
