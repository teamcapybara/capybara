# frozen_string_literal: true
RSpec.shared_context "Capybara Features", capybara_feature: true do
  instance_eval do
    alias background before
    alias given let
    alias given! let!
  end
end

# ensure shared_context is included if default shared_context_metadata_behavior is changed
if RSpec::Core::Version::STRING.to_f >= 3.5
  RSpec.configure do |config|
    config.include_context "Capybara Features", capybara_feature: true
  end
end

RSpec.configure do |config|
  config.alias_example_group_to :feature, capybara_feature: true, type: :feature
  config.alias_example_group_to :xfeature, capybara_feature: true, type: :feature, skip: "Temporarily disabled with xfeature"
  config.alias_example_group_to :ffeature, capybara_feature: true, type: :feature, focus: true
  config.alias_example_to :scenario
  config.alias_example_to :xscenario, skip: "Temporarily disabled with xscenario"
  config.alias_example_to :fscenario, focus: true
end
