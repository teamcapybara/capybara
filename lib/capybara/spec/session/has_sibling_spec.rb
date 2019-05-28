# frozen_string_literal: true

Capybara::SpecHelper.spec '#have_sibling' do
  before do
    @session.visit('/with_html')
  end

  it 'should assert a prior sibling element using the given locator' do
    el = @session.find(:css, '#mid_sibling')
    expect(el).to have_sibling(:css, '#pre_sibling')
  end

  it 'should assert a following sibling element using the given locator' do
    el = @session.find(:css, '#mid_sibling')
    expect(el).to have_sibling(:css, '#post_sibling')
  end

  it 'should not raise an error if there are multiple matches' do
    el = @session.find(:css, '#mid_sibling')
    expect(el).to have_sibling(:css, 'div')
  end

  it 'should allow counts to be specified' do
    el = @session.find(:css, '#mid_sibling')

    expect(el).to have_sibling(:css, 'div').exactly(2).times
    expect do
      expect(el).to have_sibling(:css, 'div').once
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
