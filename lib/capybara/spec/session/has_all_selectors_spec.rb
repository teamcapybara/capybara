# frozen_string_literal: true
Capybara::SpecHelper.spec '#have_all_selectors' do
  before do
    @session.visit('/with_html')
  end

  it "should be true if the given selectors are on the page" do
    expect(@session).to have_all_of_selectors(:css, "p a#foo", "h2#h2one", "h2#h2two" )
  end

  it "should be false if any of the given selectors are not on the page" do
    expect {
      expect(@session).to have_all_of_selectors(:css, "p a#foo", "h2#h2three", "h2#h2one")
    }.to raise_error ::RSpec::Expectations::ExpectationNotMetError
  end

  it "should use default selector" do
    Capybara.default_selector = :css
    expect(@session).to have_all_of_selectors("p a#foo", "h2#h2two", "h2#h2one" )
    expect {
      expect(@session).to have_all_of_selectors("p a#foo", "h2#h2three", "h2#h2one")
    }.to raise_error ::RSpec::Expectations::ExpectationNotMetError
  end

  context "should respect scopes" do
    it "when used with `within`" do
      @session.within "//p[@id='first']" do
        expect(@session).to have_all_of_selectors(".//a[@id='foo']")
        expect {
          expect(@session).to have_all_of_selectors(".//a[@id='red']")
        }.to raise_error ::RSpec::Expectations::ExpectationNotMetError
      end
    end

    it "when called on elements" do
      el = @session.find "//p[@id='first']"
      expect(el).to have_all_of_selectors(".//a[@id='foo']")
      expect {
        expect(el).to have_all_of_selectors(".//a[@id='red']")
      }.to raise_error ::RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with options" do
    it "should apply options to all locators" do
      expect(@session).to have_all_of_selectors(:field, 'normal', 'additional_newline', type: :textarea)
      expect {
        expect(@session).to have_all_of_selectors(:field, 'normal', 'test_field', 'additional_newline', type: :textarea)
      }.to raise_error ::RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with wait", requires: [:js] do
    it "should not raise error if all the elements appear before given wait duration" do
      Capybara.using_wait_time(0.1) do
        @session.visit('/with_js')
        @session.click_link('Click me')
        expect(@session).to have_all_of_selectors(:css, "a#clickable", "a#has-been-clicked", '#drag', wait: 0.9)
      end
    end
  end

  it "cannot be negated" do
    expect {
      expect(@session).not_to have_all_of_selectors(:css, "p a#foo", "h2#h2one", "h2#h2two")
    }.to raise_error ArgumentError
  end
end

