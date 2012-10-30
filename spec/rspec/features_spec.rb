require 'spec_helper'
require 'capybara/rspec'

RSpec.configuration.before(:each, :example_group => {:file_path => "./spec/rspec/features_spec.rb"}) do
  @in_filtered_hook = true
end

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

  scenario "runs hooks filtered by file path" do
    @in_filtered_hook.should be_true
  end

  scenario "doesn't pollute the Object namespace" do
    Object.new.respond_to?(:feature, true).should be_false
  end
end

feature "given and given! aliases to let and let!" do
  given(:value) { :available }
  given!(:value_in_background) { :available }

  background do
    value_in_background.should be(:available)
  end

  scenario "given and given! work as intended" do
    value.should be(:available)
    value_in_background.should be(:available)
  end
end

feature "if xscenario aliases to pending then" do
  xscenario "this test should be 'temporarily disabled with xscenario'" do
  end
end

feature "Capybara's feature DSL with driver", :driver => :culerity do
  scenario "switches driver" do
    Capybara.current_driver.should == :culerity
  end
end
