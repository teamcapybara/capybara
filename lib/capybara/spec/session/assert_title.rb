# frozen_string_literal: true
Capybara::SpecHelper.spec '#assert_title' do
  before do
    @session.visit('/with_js')
  end

  it "should be true if the page's title contains the given string" do
    expect(@session.assert_title('js')).to eq(true)
  end

  it "should be true when given an empty string" do
    expect(@session.assert_title('')).to eq(true)
  end

  it "should allow regexp matches" do
    expect(@session.assert_title(/w[a-z]{3}_js/)).to eq(true)
    expect do
      @session.assert_title(/w[a-z]{10}_js/)
    end.to raise_error(Capybara::ExpectationNotMet, 'expected "with_js" to match /w[a-z]{10}_js/')
  end

  it "should wait for title", requires: [:js] do
    @session.click_link("Change title")
    expect(@session.assert_title("changed title")).to eq(true)
  end

  it "should raise error if the title doesn't contain the given string" do
    expect do
      @session.assert_title('monkey')
    end.to raise_error(Capybara::ExpectationNotMet, 'expected "with_js" to include "monkey"')
  end

  it "should normalize given title" do
    @session.assert_title('  with_js  ')
  end

  it "should normalize given title in error message" do
    expect do
      @session.assert_title(2)
    end.to raise_error(Capybara::ExpectationNotMet, 'expected "with_js" to include "2"')
  end
end

Capybara::SpecHelper.spec '#assert_no_title' do
  before do
    @session.visit('/with_js')
  end

  it "should raise error if the title contains the given string" do
    expect do
      @session.assert_no_title('with_j')
    end.to raise_error(Capybara::ExpectationNotMet, 'expected "with_js" not to include "with_j"')
  end

  it "should allow regexp matches" do
    expect do
      @session.assert_no_title(/w[a-z]{3}_js/)
    end.to raise_error(Capybara::ExpectationNotMet, 'expected "with_js" not to match /w[a-z]{3}_js/')
    @session.assert_no_title(/monkey/)
  end

  it "should wait for title to disappear", requires: [:js] do
    @session.click_link("Change title")
    expect(@session.assert_no_title('with_js')).to eq(true)
  end

  it "should be true if the title doesn't contain the given string" do
    expect(@session.assert_no_title('monkey')).to eq(true)
  end
end
