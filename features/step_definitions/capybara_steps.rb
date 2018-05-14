# frozen_string_literal: true

When(/^I visit the (?:root|home) page$/) do
  visit('/')
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^Capybara should use the "([^"]*)" driver$/) do |driver|
  expect(Capybara.current_driver).to eq(driver.to_sym)
end

When(/^I use a matcher that fails$/) do
  begin
    expect(page).to have_css('h1#doesnotexist')
  rescue StandardError, RSpec::Expectations::ExpectationNotMetError => e
    @error_message = e.message
  end
end

Then(/^the failing exception should be nice$/) do
  expect(@error_message).to match(/expected to find visible css \"h1#doesnotexist\"/)
end
