# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Capybara RSpec Matchers', :type => :feature do
  context "after called on session" do
    it "HaveSelector should allow getting a description of the matcher" do
      visit('/with_html')
      matcher = have_selector(:css, 'h2.head', minimum: 3)
      expect(page).to matcher
      expect { matcher.description }.not_to raise_error
    end

    it "HaveText should allow getting a description" do
      visit('/with_html')
      matcher = have_text("Lorem")
      expect(page).to matcher
      expect { matcher.description }.not_to raise_error
    end
  end

  context "after called on element" do
    it "HaveSelector should allow getting a description" do
      visit('/with_html')
      el = find(:css, '#first')
      matcher = have_selector(:css, 'a#foo')
      expect(el).to matcher
      expect { matcher.description }.not_to raise_error
    end

    it "MatchSelector should allow getting a description" do
      visit('/with_html')
      el = find(:css, '#first')
      matcher = match_selector(:css, '#first')
      expect(el).to matcher
      expect { matcher.description }.not_to raise_error
    end

    it "HaveText should allow getting a description" do
      visit('/with_html')
      el = find(:css, '#first')
      matcher = have_text("Lorem")
      expect(el).to matcher
      expect { matcher.description }.not_to raise_error
    end
  end
end