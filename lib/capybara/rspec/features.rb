# frozen_string_literal: true
if RSpec::Core::Version::STRING.to_f >= 3.0
  RSpec.shared_context "Capybara Features", :capybara_feature => true do
    instance_eval do
      alias background before
      alias given let
      alias given! let!
    end
  end

  RSpec.configure do |config|
    config.alias_example_group_to :feature, :capybara_feature => true, :type => :feature
    config.alias_example_group_to :xfeature, :capybara_feature => true, :type => :feature, :skip => "Temporarily disabled with xfeature"
    config.alias_example_group_to :ffeature, :capybara_feature => true, :type => :feature, :focus => true
    config.alias_example_to :scenario
    config.alias_example_to :xscenario, :skip => "Temporarily disabled with xscenario"
    config.alias_example_to :fscenario, :focus => true
  end
else
  module Capybara
    module Features
      def self.included(base)
        base.instance_eval do
          alias :background :before
          alias :scenario :it
          alias :xscenario :xit
          alias :given :let
          alias :given! :let!
          alias :feature :describe
        end
      end
    end
  end


  def self.feature(*args, &block)
    options = if args.last.is_a?(Hash) then args.pop else {} end
    options[:capybara_feature] = true
    options[:type] = :feature
    options[:caller] ||= caller
    args.push(options)

    #call describe on RSpec in case user has expose_dsl_globally set to false
    RSpec.describe(*args, &block)
  end

  RSpec.configuration.include Capybara::Features, :capybara_feature => true
end
