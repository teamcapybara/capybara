# frozen_string_literal: true
require "rspec"
require "rspec/expectations"
require "capybara"
require "capybara/rspec" # Required here instead of in rspec_spec to avoid RSpec deprecation warning
require "capybara/spec/test_app"
require "nokogiri"

# Alias be_truthy/be_falsey if not already defined to be able to use in RSpec 2 and 3
unless RSpec::Matchers.method_defined?(:be_truthy)
  RSpec::Matchers.module_eval do
    alias be_truthy be_true
    alias be_falsey be_false
    alias be_falsy be_false
  end
end

module Capybara
  module SpecHelper
    class << self
      def configure(config)
        config.filter_run_excluding requires: method(:filter).to_proc
        config.before { Capybara::SpecHelper.reset! }
        config.after { Capybara::SpecHelper.reset! }
        # Test in 3.5+ where metadata doesn't autotrigger shared context inclusion - will be only behavior in RSpec 4
        config.shared_context_metadata_behavior = :apply_to_host_groups if RSpec::Core::Version::STRING.to_f >= 3.5
      end

      def reset!
        Capybara.app = TestApp
        Capybara.app_host = nil
        Capybara.default_selector = :xpath
        Capybara.default_max_wait_time = 1
        Capybara.ignore_hidden_elements = true
        Capybara.exact = false
        # `exact_options` is deprecated - set instancce var directly so we
        # don't generate message every reset
        Capybara.send(:config).session_options.instance_variable_set('@exact_options', false)
        Capybara.raise_server_errors = true
        Capybara.visible_text_only = false
        Capybara.match = :smart
        Capybara.wait_on_first_by_default = false
        Capybara.enable_aria_label = false
        reset_threadsafe
      end

      def filter(requires, metadata)
        if requires and metadata[:capybara_skip]
          requires.any? do |require|
            metadata[:capybara_skip].include?(require)
          end
        else
          false
        end
      end

      def spec(name, *options, &block)
        @specs ||= []
        @specs << [name, options, block]
      end

      def run_specs(session, name, options={})
        specs = @specs
        RSpec.describe Capybara::Session, name, options do
          include Capybara::SpecHelper
          include Capybara::RSpecMatchers
          before do
            @session = session
          end

          after do
            @session.reset_session!
          end

          before :each, psc: true do
            SpecHelper.reset_threadsafe(true, @session)
          end

          after psc: true do
            SpecHelper.reset_threadsafe(false, @session)
          end

          specs.each do |spec_name, spec_options, block|
            describe spec_name, *spec_options do
              class_eval(&block)
            end
          end
        end
      end

      def reset_threadsafe(bool = false, session = nil)
        Capybara::Session.class_variable_set(:@@instance_created, false) # Work around limit on when threadsafe can be changed
        Capybara.threadsafe = bool
        session = session.current_session if session.respond_to?(:current_session)
        session.instance_variable_set(:@config, nil) if session
      end
    end # class << self

    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RbConfig::CONFIG['host_os'] =~ /rmswin|mingw/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end

    def quietly
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          yield
        end
      end
    end

    def extract_results(session)
      expect(session).to have_xpath("//pre[@id='results']")
      YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.inner_html.lstrip
    end

    def marionette?(session)
      session.driver.respond_to?(:marionette?, true) && session.driver.send(:marionette?)
    end

    def rspec2?
      !defined?(::RSpec::Expectations::Version) || (Gem::Version.new(RSpec::Expectations::Version::STRING) < Gem::Version.new('3.0'))
    end
  end
end

Dir[File.dirname(__FILE__) + "/session/**/*.rb"].each { |file| require_relative file }
