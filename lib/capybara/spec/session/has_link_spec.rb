# frozen_string_literal: true

Capybara::SpecHelper.spec '#has_link?' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given link is on the page" do
    expect(@session).to have_link('foo')
    expect(@session).to have_link('awesome title')
    expect(@session).to have_link('A link', href: '/with_simple_html')
    expect(@session).to have_link(:'A link', href: :'/with_simple_html')
    expect(@session).to have_link('A link', href: %r{/with_simple_html})
  end

  it "should be false if the given link is not on the page" do
    expect(@session).not_to have_link('monkey')
    expect(@session).not_to have_link('A link', href: '/nonexistent-href')
    expect(@session).not_to have_link('A link', href: /nonexistent/)
  end
end

Capybara::SpecHelper.spec '#has_no_link?' do
  before do
    @session.visit('/with_html')
  end

  it "should be false if the given link is on the page" do
    expect(@session).not_to have_no_link('foo')
    expect(@session).not_to have_no_link('awesome title')
    expect(@session).not_to have_no_link('A link', href: '/with_simple_html')
  end

  it "should be true if the given link is not on the page" do
    expect(@session).to have_no_link('monkey')
    expect(@session).to have_no_link('A link', href: '/nonexistent-href')
    expect(@session).to have_no_link('A link', href: %r{/nonexistent-href})
  end
end
