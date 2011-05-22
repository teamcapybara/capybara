shared_examples_for "session with cookies support" do
  describe '#cookies' do
    it "should return cookies" do
      @session.visit('/set_cookie')
      @session.cookies.find { |c| c[:name] == 'capybara' }[:value].should == 'test_cookie'
    end
    it "should return a cookie by name" do
      @session.visit('/set_cookie')
      @session.cookie_named('capybara')[:value].should == 'test_cookie'
    end
  end
end
