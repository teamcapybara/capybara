# frozen_string_literal: true
Capybara::SpecHelper.spec '#visit' do
  it "should fetch a response from the driver with a relative url" do
    @session.visit('/')
    expect(@session).to have_content('Hello world!')
    @session.visit('/foo')
    expect(@session).to have_content('Another World')
  end

  it "should fetch a response from the driver with an absolute url with a port" do
    # Preparation
    @session.visit('/')
    root_uri = URI.parse(@session.current_url)

    @session.visit("http://#{root_uri.host}:#{root_uri.port}/")
    expect(@session).to have_content('Hello world!')
    @session.visit("http://#{root_uri.host}:#{root_uri.port}/foo")
    expect(@session).to have_content('Another World')
  end

  it "should fetch a response when absolute URI doesn't have a trailing slash" do
    # Preparation
    @session.visit('/foo/bar')
    root_uri = URI.parse(@session.current_url)

    @session.visit("http://#{root_uri.host}:#{root_uri.port}")
    expect(@session).to have_content('Hello world!')
  end

  it "raises any errors caught inside the server", :requires => [:server] do
    quietly { @session.visit("/error") }
    expect do
      @session.visit("/")
    end.to raise_error(TestApp::TestAppError)
  end

  it "should be able to open non-http url", requires: [:about_scheme] do
    @session.visit("about:blank")
    @session.assert_no_selector :xpath, "/html/body/*"
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
      expect(URI.parse(@session.current_url).port).to eq(root_uri.port)
      expect(@session).to have_content('Hello world!')

      @session.visit("http://#{root_uri.host}/foo")
      expect(URI.parse(@session.current_url).port).to eq(root_uri.port)
      expect(@session).to have_content('Another World')
    end
  end

  context "without a server", :requires => [:server] do
    it "should respect `app_host`" do
      serverless_session = Capybara::Session.new(@session.mode, nil)
      Capybara.app_host = "http://#{@session.server.host}:#{@session.server.port}"
      serverless_session.visit("/foo")
      expect(serverless_session).to have_content("Another World")
    end

    it "should visit a fully qualified URL" do
      serverless_session = Capybara::Session.new(@session.mode, nil)
      serverless_session.visit("http://#{@session.server.host}:#{@session.server.port}/foo")
      expect(serverless_session).to have_content("Another World")
    end
  end

  context "with Capybara.app_host set" do
    it "should override server", requires: [:server] do
      another_session = Capybara::Session.new(@session.mode, @session.app.dup)
      Capybara.app_host = "http://#{@session.server.host}:#{@session.server.port}"
      another_session.visit('/foo')
      expect(another_session).to have_content("Another World")
      expect(another_session.current_url).to start_with(Capybara.app_host)
      expect(URI.parse(another_session.current_url).port).not_to eq another_session.server.port
      expect(URI.parse(another_session.current_url).port).to eq @session.server.port
    end

    it "should append relative path", requires: [:server] do
      Capybara.app_host = "http://#{@session.server.host}:#{@session.server.port}/redirect/0"
      @session.visit('/times')
      expect(@session).to have_content('redirection complete')
    end
  end


  it "should send no referer when visiting a page" do
    @session.visit '/get_referer'
    expect(@session).to have_content 'No referer'
  end

  it "should send no referer when visiting a second page" do
    @session.visit '/get_referer'
    @session.visit '/get_referer'
    expect(@session).to have_content 'No referer'
  end

  it "should send a referer when following a link" do
    @session.visit '/referer_base'
    @session.find('//a[@href="/get_referer"]').click
    expect(@session).to have_content %r{http://.*/referer_base}
  end

  it "should preserve the original referer URL when following a redirect" do
    @session.visit('/referer_base')
    @session.find('//a[@href="/redirect_to_get_referer"]').click
    expect(@session).to have_content %r{http://.*/referer_base}
  end

  it "should send a referer when submitting a form" do
    @session.visit '/referer_base'
    @session.find('//input').click
    expect(@session).to have_content %r{http://.*/referer_base}
  end

  it "can set cookie if a blank path is specified" do
    @session.visit("")
    @session.visit('/get_cookie')
    expect(@session).to have_content('root cookie')
  end

end
