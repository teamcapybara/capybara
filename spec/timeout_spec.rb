require 'spec_helper'

require 'capybara'
require 'capybara/util/timeout'

module Capybara

  describe '.timeout' do

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

