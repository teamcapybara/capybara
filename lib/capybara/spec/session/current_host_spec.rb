shared_examples_for "current_host" do
  describe '#current_host' do
    it "is affected by visiting a page directly" do
      @session.visit('http://capybara-testapp.heroku.com/')
      @session.body.should include('Hello world')
      @session.current_host.should == 'capybara-testapp.heroku.com'
    end
  end
end
