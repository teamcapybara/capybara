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

      it "should not use data-method if option is false" do
        @session.driver.options[:respect_data_method] = false
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.body.should include('Not deleted')
      end

      after do
        @session.driver.options[:respect_data_method] = true
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
  end
end
