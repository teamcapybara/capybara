When /^I visit the root page$/ do
  visit('/')
end

Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content(text)
end

Then /^Capybara should use the "([^"]*)" driver$/ do |driver|
  Capybara.current_driver.should == driver.to_sym
end
