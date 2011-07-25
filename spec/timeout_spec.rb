require 'spec_helper'

require 'capybara'
require 'capybara/util/timeout'

module Capybara

  describe '.timeout' do

    context "with Timecop loaded" do
      let(:timecop) { stub('Stubbed Timecop', :top_stack_item => time_stack_item)}
      before { Kernel.const_set(:Timecop, timecop) }

      context "loaded, but not used" do
        let(:time_stack_item) { nil }

        it "should not raise a RuntimeError" do
          expect {
            Capybara.timeout { :finished }
          }.to_not raise_error
        end
      end

      context "with time frozen" do
        let(:time_stack_item) { stub('TimeStackItem', :mock_type => :freeze) }

        it "should raise a RuntimeError" do
          expect {
            Capybara.timeout { :finished }
          }.to raise_error(RuntimeError, "Capybara.timeout cannot work with Timecop.freeze. Use Timecop.travel instead.")
        end
      end

      context "with time travel" do
        let(:time_stack_item) { stub('TimeStackItem', :mock_type => :travel) }

        it "should not raise a RuntimeError" do
          expect {
            Capybara.timeout { :finished }
          }.to_not raise_error
        end
      end
    end

    it "should return result of yield if it returns true value within timeout" do
      Capybara.timeout { "hello" }.should == "hello"
    end

    it "should keep trying within timeout" do
      count = 0
      Capybara.timeout { count += 1; count == 5 ? count : nil }.should == 5
    end

    it "should raise Capybara::TimeoutError if block fails to return true within timeout" do
      running do
        Capybara.timeout(0.1) { false }
      end.should raise_error(::Capybara::TimeoutError)
    end

  end

end

