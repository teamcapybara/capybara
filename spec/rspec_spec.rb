require 'spec_helper'

RSpec.describe 'capybara/rspec', :type => :feature do
  it "should include Capybara in rspec" do
    visit('/foo')
    expect(page.body).to include('Another World')
  end

  context "resetting session" do
    it "sets a cookie in one example..." do
      visit('/set_cookie')
      expect(page.body).to include('Cookie set to test_cookie')
    end

    it "...then it is not available in the next" do
      visit('/get_cookie')
      expect(page.body).not_to include('test_cookie')
    end
  end

  context "setting the current driver" do
    it "sets the current driver in one example..." do
      Capybara.current_driver = :selenium
    end

    it "...then it has returned to the default in the next example" do
      expect(Capybara.current_driver).to eq(:rack_test)
    end
  end

  it "switches to the javascript driver when giving it as metadata", :js => true do
    expect(Capybara.current_driver).to eq(Capybara.javascript_driver)
  end

  it "switches to the given driver when giving it as metadata", :driver => :culerity do
    expect(Capybara.current_driver).to eq(:culerity)
  end
end

RSpec.describe 'capybara/rspec', :type => :other do
  it "should not include Capybara" do
    expect { visit('/') }.to raise_error(NoMethodError)
  end
end

feature "Feature DSL" do
  scenario "is pulled in" do
    visit('/foo')
    expect(page.body).to include('Another World')
  end
end
