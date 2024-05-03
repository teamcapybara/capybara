# frozen_string_literal: true

Capybara::SpecHelper.spec '#click_on' do
  it 'should default to being an alias for #click_link_or_button' do
    @session.visit('/form')
    @session.click_on('awe123')
    expect(extract_results(@session)['first_name']).to eq('John')
  end

  it 'should allow specifying a selector type' do
    @session.visit('/form')
    cbox = @session.click_on(:checkbox, 'form_terms_of_use')
    expect(cbox).to be_checked
  end
end
