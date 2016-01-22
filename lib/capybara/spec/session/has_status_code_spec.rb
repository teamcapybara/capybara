Capybara::SpecHelper.spec '#has_status_code?' do
  before do
    @session.visit('/form')
  end

  it 'should return equality of actual and expected session status code' do
    expect(@session).to have_status_code(200)
  end
end
