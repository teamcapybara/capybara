# frozen_string_literal: true

Capybara::SpecHelper.spec '#closest' do
  before do
    @session.visit('/with_html')
  end

  after do
    Capybara::Selector.remove(:monkey)
  end

  it 'should find closest ancestor (even if there are multiple matches)' do
    el = @session.find(:css, '#child')
    expect(el.closest(:css, 'div')[:id]).to eq 'ancestor1'
    expect(el.closest(:css, 'div', text: 'Ancestor')[:id]).to eq 'ancestor1'
    expect(el.ancestors(:css, 'div').map {|x| x[:id] }).to eq ['ancestor1', 'ancestor2', 'ancestor3']
  end
end

