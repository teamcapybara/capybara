# frozen_string_literal: true

require 'forwardable'

module Capybara
  module Options
    include Forwardable

    LEGACY_OPTIONS = %i[app server always_include_port app_host current_driver default_driver javascript_driver].freeze
    private_constant :LEGACY_OPTIONS

  private

    def define_option_methods(option)
      def_delegator :config, option
      if LEGACY_OPTIONS.include?(option)
        def_delegator :config, "#{option}="
      else
        define_method "#{option}=" do |*args, &block|
          warn "DEPRECATED: Capybara.#{option}= is deprecated, please use Capybara.configure instead [ #{caller(1, 1).first} ]"
          config.send("#{option}=", *args, &block)
        end
      end
    end
  end
end
