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
    expect(page).to have_content('Hello world!')
  end

  scenario "preserves description" do
    expect(example.metadata[:full_description]).to be_eql "Capybara's feature DSL preserves description"
  end

  scenario "allows driver switching", :driver => :selenium do
    expect(Capybara.current_driver).to be_eql :selenium
  end

  scenario "runs background" do
    expect(@in_background).to be_true
  end

  scenario "runs hooks filtered by file path" do
    expect(@in_filtered_hook).to be_true
  end

  scenario "doesn't pollute the Object namespace" do
    expect(Object.new.respond_to?(:feature, true)).to be_false
  end

  feature 'nested features' do
    scenario 'work as expected' do
      visit '/'
      expect(page).to have_content 'Hello world!'
    end

    scenario 'are marked in the metadata as capybara_feature' do
      expect(example.metadata[:capybara_feature]).to be_true
    end

    scenario 'have a type of :feature' do
      expect(example.metadata[:type]).to be_eql :feature
    end
  end
end

feature "given and given! aliases to let and let!" do
  given(:value) { :available }
  given!(:value_in_background) { :available }

  background do
    expect(value_in_background).to be(:available)
  end

  scenario "given and given! work as intended" do
    expect(value).to be(:available)
    expect(value_in_background).to be(:available)
  end
end

feature "if xscenario aliases to pending then" do
  xscenario "this test should be 'temporarily disabled with xscenario'" do
  end
end

feature "Capybara's feature DSL with driver", :driver => :culerity do
  scenario "switches driver" do
    expect(Capybara.current_driver).to be_eql :culerity
  end
end
