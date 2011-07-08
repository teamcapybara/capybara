require 'spec_helper'

describe Capybara::Session do
  context 'with rack test driver' do
    before do
      @session = TestSessions::Mechanize
    end

    describe '#driver' do
      it "should be a rack test driver" do
        @session.driver.should be_an_instance_of(Capybara::Mechanize::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :mechanize
      end
    end

    describe '#click_link' do
      it "should use data-method if available" do
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.body.should include('The requested object was deleted')
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end
