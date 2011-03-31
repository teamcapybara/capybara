module Capybara
  module Features
    def self.included(base)
      base.instance_eval do
        alias :background :before
        alias :scenario :it
      end
    end
  end
end

def self.feature(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:capybara_feature] = true
  options[:type] = :request
  options[:caller] ||= caller
  args.push(options)

  describe(*args, &block)
end

RSpec.configuration.include Capybara::Features, :capybara_feature => true
