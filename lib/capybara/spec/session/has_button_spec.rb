# frozen_string_literal: true

Capybara::SpecHelper.spec '#has_button?' do
  before do
    @session.visit('/form')
  end

  it 'should be true if the given button is on the page' do
    expect(@session).to have_button('med')
    expect(@session).to have_button('crap321')
    expect(@session).to have_button(:crap321)
  end

  it 'should be true for disabled buttons if disabled: true' do
    expect(@session).to have_button('Disabled button', disabled: true)
  end

  it 'should be false if the given button is not on the page' do
    expect(@session).not_to have_button('monkey')
  end

  it 'should be false for disabled buttons by default' do
    expect(@session).not_to have_button('Disabled button')
  end

  it 'should be false for disabled buttons if disabled: false' do
    expect(@session).not_to have_button('Disabled button', disabled: false)
  end

  it 'should be true for disabled buttons if disabled: :all' do
    expect(@session).to have_button('Disabled button', disabled: :all)
  end

  it 'should be true for enabled buttons if disabled: :all' do
    expect(@session).to have_button('med', disabled: :all)
  end

  it 'can verify button type' do
    expect(@session).to have_button('awe123', type: 'submit')
    expect(@session).not_to have_button('awe123', type: 'reset')
  end
end

Capybara::SpecHelper.spec '#has_no_button?' do
  before do
    @session.visit('/form')
  end

  it 'should be true if the given button is on the page' do
    expect(@session).not_to have_no_button('med')
    expect(@session).not_to have_no_button('crap321')
  end

  it 'should be true for disabled buttons if disabled: true' do
    expect(@session).not_to have_no_button('Disabled button', disabled: true)
  end

  it 'should be false if the given button is not on the page' do
    expect(@session).to have_no_button('monkey')
  end

  it 'should be false for disabled buttons by default' do
    expect(@session).to have_no_button('Disabled button')
  end

  it 'should be false for disabled buttons if disabled: false' do
    expect(@session).to have_no_button('Disabled button', disabled: false)
  end
end
