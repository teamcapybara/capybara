require 'spec_helper'

describe Capybara::Driver::Selenium do
  before do
    @driver = TestSessions::Selenium.driver
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with frame support"
  it_should_behave_like "driver with support for window switching"
  it_should_behave_like "driver without status code support"
  it_should_behave_like "driver with cookies support"

  describe "Node" do
    before do
      @driver = mock
      @native = mock
      @node = Capybara::Driver::Selenium::Node.new(@driver, @native)
    end

    describe "#text" do
      it "returns text from the native driver" do
        @native.should_receive(:text).and_return('happy capybara')
        @node.text.should == 'happy capybara'
      end

      it "returns '' if the the element has been removed from the dom" do
        @native.should_receive(:text).and_raise(Selenium::WebDriver::Error::ObsoleteElementError.new('angry capybara'))
        @node.text.should == ''
      end
    end

    describe "#visible?" do
      it "returns visibility based on the native driver" do
        @native.should_receive(:displayed?).and_return('true')
        @node.should be_visible
        @native.should_receive(:displayed?).and_return('false')
        @node.should_not be_visible
      end

      it "returns text from the native driver" do
        @native.should_receive(:displayed?).and_raise(Selenium::WebDriver::Error::ObsoleteElementError.new('angry capybara'))
        @node.should_not be_visible
      end
    end
  end
end
