Capybara::SpecHelper.spec '#save_screenshot', requires: [:screenshot] do
  before do
    @session.visit '/foo'
  end

  it "generates sensible filename" do
    allow(@session.driver).to receive(:save_screenshot)

    @session.save_screenshot

    regexp = Regexp.new(File.expand_path('capybara-\d+\.png'))
    expect(@session.driver).to have_received(:save_screenshot).with(regexp, {})
  end

  it "allows to specify another path" do
    allow(@session.driver).to receive(:save_screenshot)

    custom_path = 'screenshots/1.png'
    @session.save_screenshot(custom_path)

    expect(@session.driver).to have_received(:save_screenshot).with(custom_path, {})
  end
end
