# frozen_string_literal: true

Capybara::SpecHelper.spec '#has_link?' do
  before do
    @session.visit('/with_html')
  end

  it 'should be true if the given link is on the page' do
    expect(@session).to have_link('foo')
    expect(@session).to have_link('awesome title')
    expect(@session).to have_link('A link', href: '/with_simple_html')
    expect(@session).to have_link(:'A link', href: :'/with_simple_html')
    expect(@session).to have_link('A link', href: %r{/with_simple_html})
  end

  it 'should be false if the given link is not on the page' do
    expect(@session).not_to have_link('monkey')
    expect(@session).not_to have_link('A link', href: '/nonexistent-href')
    expect(@session).not_to have_link('A link', href: /nonexistent/)
  end

  context 'with described_by:' do
    it 'should be true if link is described by the text' do
      expect(@session).to have_link(described_by: 'description (part 1)')
      expect(@session).to have_link(described_by: 'description (part 2)')
      expect(@session).to have_link(described_by: 'description (part 1) description (part 2)')
      expect(@session).to have_link('Link with aria-describedby', described_by: 'description (part 1)')
      expect(@session).to have_link('Link with aria-describedby', described_by: 'description (part 2)')
      expect(@session).to have_link('Link with aria-describedby', described_by: 'description (part 1) description (part 2)')
    end

    it 'should be false if the link is described by missing elements' do
      expect(@session).not_to have_link(described_by: 'elements are missing')
      expect(@session).not_to have_link('Link described by missing elements', described_by: 'elements are missing')
    end

    it 'should be false if link is not described by the text' do
      expect(@session).not_to have_link('Link with aria-describedby', described_by: 'does not exist')
    end
  end
end

Capybara::SpecHelper.spec '#has_no_link?' do
  before do
    @session.visit('/with_html')
  end

  it 'should be false if the given link is on the page' do
    expect(@session).not_to have_no_link('foo')
    expect(@session).not_to have_no_link('awesome title')
    expect(@session).not_to have_no_link('A link', href: '/with_simple_html')
  end

  it 'should be true if the given link is not on the page' do
    expect(@session).to have_no_link('monkey')
    expect(@session).to have_no_link('A link', href: '/nonexistent-href')
    expect(@session).to have_no_link('A link', href: %r{/nonexistent-href})
  end

  context 'with described_by:' do
    it 'should be true if link is not described by the text' do
      expect(@session).to have_no_link('Link with aria-describedby', described_by: 'does not exist')
    end

    it 'should be true if the link is described by missing elements' do
      expect(@session).to have_no_link(described_by: 'elements are missing')
      expect(@session).to have_no_link('Link described by missing elements', described_by: 'elements are missing')
    end

    it 'should be false if link is described by the text' do
      expect(@session).not_to have_no_link(described_by: 'description (part 1)')
      expect(@session).not_to have_no_link(described_by: 'description (part 2)')
      expect(@session).not_to have_no_link(described_by: 'description (part 1) description (part 2)')
      expect(@session).not_to have_no_link('Link with aria-describedby', described_by: 'description (part 1)')
      expect(@session).not_to have_no_link('Link with aria-describedby', described_by: 'description (part 2)')
      expect(@session).not_to have_no_link('Link with aria-describedby', described_by: 'description (part 1) description (part 2)')
    end
  end
end
