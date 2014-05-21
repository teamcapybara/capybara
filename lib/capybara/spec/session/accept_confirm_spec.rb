Capybara::SpecHelper.spec '#accept_confirm', :requires => [:modals] do
  before do
    @session.visit('/with_js')
  end

  it "should accept the confirm" do
    @session.accept_confirm do
      @session.click_link('Open confirm')
    end
    expect(@session).to have_xpath("//a[@id='open-confirm' and @confirmed='true']")
  end

  it "should return the message presented" do
    message = @session.accept_confirm do
      @session.click_link('Open confirm')
    end
    expect(message).to eq('Confirm opened')
  end
end