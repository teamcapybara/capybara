Capybara::SpecHelper.spec '#accept_alert', :requires => [:modals] do
  before do
    @session.visit('/with_js')
  end

  it "should accept the alert" do
    @session.accept_alert do
      @session.click_link('Open alert')
    end
    expect(@session).to have_xpath("//a[@id='open-alert' and @opened='true']")
  end

  it "should return the message presented" do
    message = @session.accept_alert do
      @session.click_link('Open alert')
    end
    expect(message).to eq('Alert opened')
  end

  context "with an asynchronous alert" do
    it "should accept the alert" do
      @session.accept_alert do
        @session.click_link('Open delayed alert')
      end
      expect(@session).to have_xpath("//a[@id='open-delayed-alert' and @opened='true']")
    end

    it "should return the message presented" do
      message = @session.accept_alert do
        @session.click_link('Open delayed alert')
      end
      expect(message).to eq('Delayed alert opened')
    end
  end
end