require 'spec_helper'

describe Capybara::Session do
  context 'with rack test driver' do
    before do
      @session = TestSessions::RackTest
    end

    describe '#driver' do
      it "should be a rack test driver" do
        @session.driver.should be_an_instance_of(Capybara::RackTest::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :rack_test
      end
    end

    describe '#click_link' do
      it "should use data-method if available" do
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.body.should include('The requested object was deleted')
      end
    end

    describe "#attach_file" do
      context "with multipart form" do
        it "should submit an empty form-data section if no file is submitted" do
          @session.visit("/form")
          @session.click_button("Upload Empty")
          @session.body.should include('Successfully ignored empty file field.')
        end
      end
    end

    it_should_behave_like "session"
    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"

    describe "session #current_host" do
      after do
        Capybara.app_host = nil
      end
      it "is affected by the current protocol" do
        @session.visit('https://capybara-testapp.heroku.com/host_links')
        @session.click_button('Relative Host')
        @session.body.should include('Current host is https://capybara-testapp.heroku.com')
        @session.current_host.should == 'https://capybara-testapp.heroku.com'
      end

      it "is affected by the protocol of the latest redirect" do
        @session.visit('http://capybara-testapp.heroku.com/host_links_over_ssl')
        @session.click_button('Relative Host')
        @session.body.should include('Current host is https://capybara-testapp.heroku.com')
        @session.current_host.should == 'https://capybara-testapp.heroku.com'
      end
    end

  end
end
