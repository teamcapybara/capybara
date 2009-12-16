require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'nokogiri'

shared_examples_for "session without javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_js') }
    it "should raise an error" do
      running {
        @session.evaluate_script("1+5")
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
 