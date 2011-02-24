When /^I visit the (?:root|home) page$/ do
  visit('/')
end

Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content(text)
end

Then /^Capybara should use the "([^"]*)" driver$/ do |driver|
  Capybara.current_driver.should == driver.to_sym
end

When /^I use a matcher that fails$/ do
  begin
    page.should have_css('h1#doesnotexist')
  rescue StandardError => e
    @error_message = e.message
  end
end

Then /^the failing exception should be nice$/ do
  @error_message.should =~ %r(expected css \"h1#doesnotexist\" to return)
end

