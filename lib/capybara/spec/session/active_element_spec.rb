# frozen_string_literal: true

Capybara::SpecHelper.spec '#active_element', requires: [:js] do
  it 'should return the active element' do
    @session.visit('/form')
    @session.send_keys(:tab)

    expect(@session.active_element).to eq(@session.find_by_id('form_title'))

    @session.send_keys(:tab)

    expect(@session.active_element).not_to eq(@session.find_by_id('form_title'))
  end
end
