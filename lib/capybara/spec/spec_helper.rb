require "rspec"
require "capybara"
require "capybara/rspec" # Required here instead of in rspec_spec to avoid RSpec deprecation warning
require "capybara/spec/test_app"
require "nokogiri"

module Capybara
  module SpecHelper
    class << self
      def configure(config)
        config.filter_run_excluding :requires => method(:filter).to_proc
        config.before { Capybara::SpecHelper.reset! }
        config.after { Capybara::SpecHelper.reset! }
      end

      def reset!
        Capybara.app = TestApp
        Capybara.app_host = nil
        Capybara.default_selector = :xpath
        Capybara.default_wait_time = 1
        Capybara.ignore_hidden_elements = true
        Capybara.exact = false
        Capybara.exact_options = false
        Capybara.raise_server_errors = true
        Capybara.visible_text_only = false
        Capybara.match = :smart
      end

      def filter(requires, metadata)
        if requires and metadata[:skip]
          requires.any? do |require|
            metadata[:skip].include?(require)
          end
        else
          false
        end
      end

      def spec(name, options={}, &block)
        @specs ||= []
        @specs << [name, options, block]
      end

      def run_specs(session, name, options={})
        specs = @specs
        describe Capybara::Session, name, options do
          include Capybara::SpecHelper
          before do
            @session = session
          end
          after do
            @session.reset_session!
          end
          specs.each do |spec_name, spec_options, block|
            describe spec_name, spec_options do
              class_eval(&block)
            end
          end
        end
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
      YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text.lstrip
    end
  end
end

Dir[File.dirname(__FILE__)+'/session/*'].each { |group| require group }
