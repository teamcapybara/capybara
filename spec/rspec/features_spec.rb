require 'spec_helper'
require 'capybara/rspec'

RSpec.configuration.before(:each, { file_path: "./spec/rspec/features_spec.rb" } ) do
  @in_filtered_hook = true
end

feature "Capybara's feature DSL" do    
  background do
    @in_background = true
  end
  
  def current_example(context)
    RSpec.respond_to?(:current_example) ? RSpec.current_example : context.example
  end

  scenario "includes Capybara" do
    visit('/')
    expect(page).to have_content('Hello world!')
  end

  scenario "preserves description" do 
    expect(current_example(self).metadata[:full_description])
      .to eq("Capybara's feature DSL preserves description")
  end

  scenario "allows driver switching", :driver => :selenium do
    expect(Capybara.current_driver).to eq(:selenium)
  end

  scenario "runs background" do
    expect(@in_background).to be_truthy
  end

  scenario "runs hooks filtered by file path" do
    expect(@in_filtered_hook).to be_truthy
  end

  scenario "doesn't pollute the Object namespace" do
    expect(Object.new.respond_to?(:feature, true)).to be_falsey
  end

  feature 'nested features' do
    scenario 'work as expected' do
      visit '/'
      expect(page).to have_content 'Hello world!'
    end

    scenario 'are marked in the metadata as capybara_feature' do
      expect(current_example(self).metadata[:capybara_feature]).to be_truthy
    end

    scenario 'have a type of :feature' do
      expect(current_example(self).metadata[:type]).to eq :feature
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

feature "Capybara's feature DSL with driver", :driver => :culerity do
  scenario "switches driver" do
    expect(Capybara.current_driver).to eq(:culerity)
  end
end

if RSpec::Core::Version::STRING.to_f >= 3.0
  xfeature "if xfeature aliases to pending then" do
    scenario "this should be 'temporarily disabled with xfeature'" do; end
    scenario "this also should be 'temporarily disabled with xfeature'" do; end
  end

  ffeature "if ffeature aliases focused tag then" do
    scenario "scenario inside this feature has metatag focus tag" do |example|
      expect(example.metadata[:focus]).to eq true
    end

    scenario "other scenarios also has metatag focus tag " do |example|
      expect(example.metadata[:focus]).to eq true
    end
  end
end
