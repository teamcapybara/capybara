# frozen_string_literal: true

Capybara::SpecHelper.spec '#ancestors' do
  before do
    @session.visit('/with_html')
  end

  after do
    Capybara::Selector.remove(:monkey)
  end

  it 'should find all matching ancestors' do
    el = @session.find(:css, '#child')
    expect(el.ancestors(:css, 'div').map {|x| x[:id] }).to eq ['ancestor1', 'ancestor2', 'ancestor3']
    expect(el.all_ancestors(:css, 'div').map {|x| x[:id] }).to eq ['ancestor1', 'ancestor2', 'ancestor3']
  end
end

