Capybara::SpecHelper.spec '#visit' do
  it "should fetch a response from the driver with a relative url" do
    @session.visit('/')
    @session.should have_content('Hello world!')
    @session.visit('/foo')
    @session.should have_content('Another World')
  end

  it "should fetch a response from the driver with an absolute url with a port" do
    # Preparation
    @session.visit('/')
    root_uri = URI.parse(@session.current_url)

    @session.visit("http://#{root_uri.host}:#{root_uri.port}/")
    @session.should have_content('Hello world!')
    @session.visit("http://#{root_uri.host}:#{root_uri.port}/foo")
    @session.should have_content('Another World')
  end

  it "should fetch a response when absolute URI doesn't have a trailing slash" do
    # Preparation
    @session.visit('/foo/bar')
    root_uri = URI.parse(@session.current_url)

    @session.visit("http://localhost:#{root_uri.port}")
    @session.should have_content('Hello world!')
  end

  context "when Capybara.always_include_port is true" do

    let(:root_uri) do
      @session.visit('/')
      URI.parse(@session.current_url)
    end

    before(:each) do
      Capybara.always_include_port = true
    end

    after(:each) do
      Capybara.always_include_port = false
    end

    it "should fetch a response from the driver with an absolute url without a port" do
      @session.visit("http://#{root_uri.host}/")
      URI.parse(@session.current_url).port.should == root_uri.port
      @session.should have_content('Hello world!')

      @session.visit("http://#{root_uri.host}/foo")
      URI.parse(@session.current_url).port.should == root_uri.port
      @session.should have_content('Another World')
    end
  end

  context "without a server", :requires => [:server] do
    it "should respect `app_host`" do
      serverless_session = Capybara::Session.new(@session.mode, nil)
      Capybara.app_host = "http://#{@session.server.host}:#{@session.server.port}"
      serverless_session.visit("/foo")
      serverless_session.should have_content("Another World")
    end

    it "should visit a fully qualified URL" do
      serverless_session = Capybara::Session.new(@session.mode, nil)
      serverless_session.visit("http://#{@session.server.host}:#{@session.server.port}/foo")
      serverless_session.should have_content("Another World")
    end
  end

  it "should send no referer when visiting a page" do
    @session.visit '/get_referer'
    @session.should have_content 'No referer'
  end

  it "should send no referer when visiting a second page" do
    @session.visit '/get_referer'
    @session.visit '/get_referer'
    @session.should have_content 'No referer'
  end

  it "should send a referer when following a link" do
    @session.visit '/referer_base'
    @session.find('//a[@href="/get_referer"]').click
    @session.should have_content %r{http://.*/referer_base}
  end

  it "should preserve the original referer URL when following a redirect" do
    @session.visit('/referer_base')
    @session.find('//a[@href="/redirect_to_get_referer"]').click
    @session.should have_content %r{http://.*/referer_base}
  end

  it "should send a referer when submitting a form" do
    @session.visit '/referer_base'
    @session.find('//input').click
    @session.should have_content %r{http://.*/referer_base}
  end

  it "can set cookie if a blank path is specified" do
    @session.visit("")
    @session.visit('/get_cookie')
    @session.should have_content('root cookie')
  end

end
