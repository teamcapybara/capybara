require 'spec_helper'
require 'capybara/rspec'

Capybara.app = TestApp

feature "Capybara's feature DSL" do
  background do
    @in_background = true
  end

  scenario "includes Capybara" do
    visit('/')
    page.should have_content('Hello world!')
  end

  scenario "preserves description" do
    example.metadata[:full_description].should == "Capybara's feature DSL preserves description"
  end

  scenario "allows driver switching", :driver => :selenium do
    Capybara.current_driver.should == :selenium
  end

  scenario "runs background" do
    @in_background.should be_true
  end
end

feature "Capybara's feature DSL with driver", :driver => :culerity do
  scenario "switches driver" do
    Capybara.current_driver.should == :culerity
  end
end
