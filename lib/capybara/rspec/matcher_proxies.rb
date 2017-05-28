# frozen_string_literal: true
module Capybara
  module RSpecMatcherProxies
    def all(*args)
      if defined?(::RSpec::Matchers::BuiltIn::All) && args.first.respond_to?(:matches?)
        ::RSpec::Matchers::BuiltIn::All.new(*args)
      else
        find_all(*args)
      end
    end

    def within(*args)
      if block_given?
        within_element(*args, &Proc.new)
      else
        be_within(*args)
      end
    end
  end

  module DSL
    class <<self
      remove_method :included

      def included(base)
        warn "including Capybara::DSL in the global scope is not recommended!" if base == Object

        if defined?(::RSpec::Matchers) && base.include?(::RSpec::Matchers)
          base.send(:include, ::Capybara::RSpecMatcherProxies)
        end

        super
      end
    end
  end
end

if defined?(::RSpec::Matchers)
  module  ::RSpec::Matchers
    def self.included(base)
      base.send(:include, ::Capybara::RSpecMatcherProxies) if base.include?(::Capybara::DSL)
      super
    end
  end
end
