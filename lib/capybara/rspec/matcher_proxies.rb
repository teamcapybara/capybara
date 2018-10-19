# frozen_string_literal: true

module Capybara
  module RSpecMatcherProxies
    def all(*args, &block)
      if defined?(::RSpec::Matchers::BuiltIn::All) && args.first.respond_to?(:matches?)
        ::RSpec::Matchers::BuiltIn::All.new(*args)
      else
        find_all(*args, &block)
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

  if RUBY_ENGINE == "jruby"
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
  else
    module DSLRSpecProxyInstaller
      module ClassMethods
        def included(base)
          if defined?(::RSpec::Matchers)
            base.include(::Capybara::RSpecMatcherProxies) if base.include?(::RSpec::Matchers)
          end
          super
        end
      end

      def self.prepended(base)
        class <<base
          prepend ClassMethods
        end
      end
    end

    module RSpecMatcherProxyInstaller
      module ClassMethods
        def included(base)
          base.include(::Capybara::RSpecMatcherProxies) if base.include?(::Capybara::DSL)
          super
        end
      end

      def self.prepended(base)
        class <<base
          prepend ClassMethods
        end
      end
    end

    DSL.prepend ::Capybara::DSLRSpecProxyInstaller
  end
end

if defined?(::RSpec::Matchers)
  module ::RSpec::Matchers
    if RUBY_ENGINE == "jruby"
      def self.included(base)
        base.send(:include, ::Capybara::RSpecMatcherProxies) if base.include?(::Capybara::DSL)
        super
      end
    else
      prepend ::Capybara::RSpecMatcherProxyInstaller
    end
  end
end
