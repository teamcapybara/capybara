Capybara::SpecHelper.spec '#respond_to_prompt', :requires => [:modals] do
  before do
    @session.visit('/with_js')
  end

  it "should accept the prompt" do
    @session.respond_to_prompt 'the response' do
      @session.click_link('Open prompt')
    end
    expect(@session).to have_xpath("//a[@id='open-prompt' and @response='the response']")
  end

  it "should return the message presented" do
    message = @session.respond_to_prompt 'the response' do
      @session.click_link('Open prompt')
    end
    expect(message).to eq('Prompt opened')
  end
end