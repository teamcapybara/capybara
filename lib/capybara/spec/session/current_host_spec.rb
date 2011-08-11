shared_examples_for "current_host" do
  after do
    Capybara.app_host = nil
  end

  describe '#current_host' do
    it "is affected by visiting a page directly" do
      @session.visit('http://capybara-testapp.heroku.com/host')
      @session.body.should include('Current host is http://capybara-testapp.heroku.com')
      @session.current_host.should == 'http://capybara-testapp.heroku.com'
    end

    it "returns to the app host when visiting a relative url" do
      Capybara.app_host = "http://capybara1.elabs.se"
      @session.visit('http://capybara-testapp.heroku.com/host')
      @session.body.should include('Current host is http://capybara-testapp.heroku.com')
      @session.current_host.should == 'http://capybara-testapp.heroku.com'
      @session.visit('/host')
      @session.body.should include('Current host is http://capybara1.elabs.se')
      @session.current_host.should == 'http://capybara1.elabs.se'
    end

    it "is affected by setting Capybara.app_host" do
      Capybara.app_host = "http://capybara-testapp.heroku.com"
      @session.visit('/host')
      @session.body.should include('Current host is http://capybara-testapp.heroku.com')
      @session.current_host.should == 'http://capybara-testapp.heroku.com'
      Capybara.app_host = "http://capybara1.elabs.se"
      @session.visit('/host')
      @session.body.should include('Current host is http://capybara1.elabs.se')
      @session.current_host.should == 'http://capybara1.elabs.se'
    end

    it "is unaffected by following a relative link" do
      @session.visit('http://capybara-testapp.heroku.com/host_links')
      @session.click_link('Relative Host')
      @session.body.should include('Current host is http://capybara-testapp.heroku.com')
      @session.current_host.should == 'http://capybara-testapp.heroku.com'
    end

    it "is affected by following an absolute link" do
      @session.visit('http://capybara-testapp.heroku.com/host_links')
      @session.click_link('Absolute Host')
      @session.body.should include('Current host is http://capybara2.elabs.se')
      @session.current_host.should == 'http://capybara2.elabs.se'
    end

    it "is unaffected by posting through a relative form" do
      @session.visit('http://capybara-testapp.heroku.com/host_links')
      @session.click_button('Relative Host')
      @session.body.should include('Current host is http://capybara-testapp.heroku.com')
      @session.current_host.should == 'http://capybara-testapp.heroku.com'
    end

    it "is affected by posting through an absolute form" do
      @session.visit('http://capybara-testapp.heroku.com/host_links')
      @session.click_button('Absolute Host')
      @session.body.should include('Current host is http://capybara2.elabs.se')
      @session.current_host.should == 'http://capybara2.elabs.se'
    end

    it "is affected by following a redirect" do
      @session.visit('http://capybara-testapp.heroku.com/redirect_secure')
      @session.body.should include('Current host is https://capybara-testapp.heroku.com')
      @session.current_host.should == 'https://capybara-testapp.heroku.com'
    end
  end
end
