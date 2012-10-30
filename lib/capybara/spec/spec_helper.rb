require "rspec"
require "capybara"
require "capybara/rspec" # Required here instead of in rspec_spec to avoid RSpec deprecation warning
require "capybara/spec/test_app"
require "capybara/spec/spec_helper"
require "nokogiri"

module Capybara
  module SpecHelper
    class << self
      def configure(config)
        filter = lambda do |requires, metadata|
          if requires and metadata[:skip]
            requires.any? do |require|
              metadata[:skip].include?(require)
            end
          else
            false
          end
        end
        config.filter_run_excluding :requires => filter
        config.before do
          Capybara.app = TestApp

          Capybara.configure do |config|
            config.default_selector = :xpath
          end

          Capybara.default_wait_time = 1
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
          specs.each do |name, options, block|
            describe name, options do
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

RSpec.configure do |config|
  Capybara::SpecHelper.configure(config)
end

Dir[File.dirname(__FILE__)+'/session/*'].each { |group| require group }
