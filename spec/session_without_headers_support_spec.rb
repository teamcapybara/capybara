require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'nokogiri'

shared_examples_for "session without headers support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.response_headers
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
 