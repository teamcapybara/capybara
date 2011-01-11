require 'spec_helper'
require 'capybara/rspec'

Capybara.app = TestApp

describe 'capybara/rspec', :type => :acceptance do
  it "should include Capybara in rpsec" do
    visit('/foo')
    page.body.should include('Another World')
  end

  context "resetting session" do
    it "sets a cookie in one example..." do
      visit('/set_cookie')
      page.body.should include('Cookie set to test_cookie')
    end

    it "...then it is not availbable in the next" do
      visit('/get_cookie')
      page.body.should_not include('test_cookie')
    end
  end

  context "setting the current driver" do
    it "sets the current driver in one example..." do
      Capybara.current_driver = :selenium
    end

    it "...then it has returned to the default in the next example" do
      Capybara.current_driver.should == :rack_test
    end
  end

  it "switches to the javascript driver when giving it as metadata", :js => true do
    Capybara.current_driver.should == Capybara.javascript_driver
  end

  it "switches to the given driver when giving it as metadata", :driver => :culerity do
    Capybara.current_driver.should == :culerity
  end
end

describe 'capybara/rspec', :type => :other do
  it "should not include Capybara" do
    expect { visit('/') }.to raise_error(NoMethodError)
  end
end

describe Capybara::RSpec::StringMatchers do
  include Capybara::RSpec::StringMatchers
  before { Capybara.default_selector = :css }
  after  { Capybara.default_selector = :xpath }
  describe "have_css matcher" do
    context "with should" do
      it "passes if has_css? returns true" do
        "<h1>Text</h1>".should have_css('h1')
      end

      it "fails if has_css? returns false" do
        expect do
          "<h1>Text</h1>".should have_css('h2')
        end.to raise_error(/expected css .* to return something/)
      end
    end

    context "with should_not" do
      it "passes if has_no_css? returns true" do
        "<h1>Text</h1>".should_not have_css('h2')
      end

      it "fails if has_no_css? returns false" do
        expect do
          "<h1>Text</h1>".should_not have_css('h1')
        end.to raise_error(/expected css .* not to return anything/)
      end
    end
  end

  describe "have_xpath matcher" do
    context "with should" do
      it "passes if has_xpath? returns true" do
        "<h1>Text</h1>".should have_xpath('//h1')
      end

      it "fails if has_xpath? returns false" do
        expect do
          "<h1>Text</h1>".should have_xpath('//h2')
        end.to raise_error(/expected xpath .* to return something/)
      end
    end

    context "with should_not" do
      it "passes if has_no_xpath? returns true" do
        "<h1>Text</h1>".should_not have_xpath('//h2')
      end

      it "fails if has_no_xpath? returns false" do
        expect do
          "<h1>Text</h1>".should_not have_xpath('//h1')
        end.to raise_error(/expected xpath .* not to return anything/)
      end
    end
  end

  describe "have_selector matcher" do
    context "with should" do
      it "passes if has_selector? returns true" do
        "<h1>Text</h1>".should have_selector('h1')
      end

      it "fails if has_selector? returns false" do
        expect do
          "<h1>Text</h1>".should have_selector('h2')
        end.to raise_error(/expected selector .* to return something/)
      end
    end

    context "with should_not" do
      it "passes if has_no_selector? returns true" do
        "<h1>Text</h1>".should_not have_selector('h2')
      end

      it "fails if has_no_selector? returns false" do
        expect do
          "<h1>Text</h1>".should_not have_selector('h1')
        end.to raise_error(/expected selector .* not to return anything/)
      end
    end
  end
end
