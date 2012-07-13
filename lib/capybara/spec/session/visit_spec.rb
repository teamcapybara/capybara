shared_examples_for "visit" do
  describe '#visit' do
    it "should fetch a response from the driver with a relative url" do
      @session.visit('/')
      @session.body.should include('Hello world!')
      @session.visit('/foo')
      @session.body.should include('Another World')
    end

    it "should fetch a response from the driver with an absolute url with a port" do
      # Preparation
      @session.visit('/')
      root_uri = URI.parse(@session.current_url)

      @session.visit("http://#{root_uri.host}:#{root_uri.port}/")
      @session.body.should include('Hello world!')
      @session.visit("http://#{root_uri.host}:#{root_uri.port}/foo")
      @session.body.should include('Another World')
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
        @session.body.should include('Hello world!')

        @session.visit("http://#{root_uri.host}/foo")
        URI.parse(@session.current_url).port.should == root_uri.port
        @session.body.should include('Another World')
      end
    end

    it "should send no referer when visiting a page" do
      @session.visit '/get_referer'
      @session.body.should include 'No referer'
    end

    it "should send no referer when visiting a second page" do
      @session.visit '/get_referer'
      @session.visit '/get_referer'
      @session.body.should include 'No referer'
    end

    it "should send a referer when following a link" do
      @session.visit '/referer_base'
      @session.find('//a[@href="/get_referer"]').click
      @session.body.should match %r{http://.*/referer_base}
    end

    it "should preserve the original referer URL when following a redirect" do
      @session.visit('/referer_base')
      @session.find('//a[@href="/redirect_to_get_referer"]').click
      @session.body.should match %r{http://.*/referer_base}
    end

    it "should send a referer when submitting a form" do
      @session.visit '/referer_base'
      @session.find('//input').click
      @session.body.should match %r{http://.*/referer_base}
    end
  end
end
