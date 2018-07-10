# frozen_string_literal: true

Capybara::SpecHelper.spec '#has_style?', requires: [:css] do
  before do
    @session.visit('/with_html')
  end

  it 'should be true if the element has the given style' do
    expect(@session.find(:css, '#first')).to have_style(display: 'block')
    expect(@session.find(:css, '#first').has_style?(display: 'block')).to be true
    expect(@session.find(:css, '#second')).to have_style('display' => 'inline')
    expect(@session.find(:css, '#second').has_style?('display' => 'inline')).to be true
  end

  it 'should be false if the element does not have the given style' do
    expect(@session.find(:css, '#first').has_style?('display' => 'inline')).to be false
    expect(@session.find(:css, '#second').has_style?(display: 'block')).to be false
  end

  it 'allows Regexp for value matching' do
    expect(@session.find(:css, '#first')).to have_style(display: /^bl/)
    expect(@session.find(:css, '#first').has_style?('display' => /^bl/)).to be true
    expect(@session.find(:css, '#first').has_style?(display: /^in/)).to be false
  end
end
