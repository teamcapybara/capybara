Capybara::SpecHelper.spec '#accept_prompt', :requires => [:modals] do
  before do
    @session.visit('/with_js')
  end

  it "should accept the prompt with no message" do
    @session.accept_prompt do
      @session.click_link('Open prompt')
    end
    expect(@session).to have_xpath("//a[@id='open-prompt' and @response='']")
  end

  it "should return the message presented" do
    message = @session.accept_prompt do
      @session.click_link('Open prompt')
    end
    expect(message).to eq('Prompt opened')
  end
end