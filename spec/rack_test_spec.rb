require 'spec_helper'

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::RackTest, "RackTest", :skip => [
  :js,
  :screenshot,
  :frames,
  :windows,
  :server,
  :hover
]

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
      it "should use data-method if option is true" do
        @session.driver.options[:respect_data_method] = true
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.html.should include('The requested object was deleted')
      end

      it "should not use data-method if option is false" do
        @session.driver.options[:respect_data_method] = false
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.html.should include('Not deleted')
      end

      it "should use data-method if available even if it's capitalized" do
        @session.driver.options[:respect_data_method] = true
        @session.visit "/with_html"
        @session.click_link "A link with capitalized data-method"
        @session.html.should include('The requested object was deleted')
      end

      after do
        @session.driver.options[:respect_data_method] = false
      end
    end

    describe "#attach_file" do
      context "with multipart form" do
        it "should submit an empty form-data section if no file is submitted" do
          @session.visit("/form")
          @session.click_button("Upload Empty")
          @session.html.should include('Successfully ignored empty file field.')
        end
      end
    end
  end
end

describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::RackTest.driver
  end

  describe ':headers option' do
    it 'should always set headers' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header')
      @driver.html.should include('foobar')
    end

    it 'should keep headers on link clicks' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find_xpath('.//a').first.click
      @driver.html.should include('foobar')
    end

    it 'should keep headers on form submit' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find_xpath('.//input').first.click
      @driver.html.should include('foobar')
    end

    it 'should keep headers on redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header_via_redirect')
      @driver.html.should include('foobar')
    end
  end

  describe ':follow_redirects option' do
    it "defaults to following redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp)

      @driver.visit('/redirect')
      @driver.response.header['Location'].should be_nil
      @driver.browser.current_url.should match %r{/landed$}
    end

    it "is possible to not follow redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp, :follow_redirects => false)

      @driver.visit('/redirect')
      @driver.response.header['Location'].should match %r{/redirect_again$}
      @driver.browser.current_url.should match %r{/redirect$}
    end
  end

  describe ':redirect_limit option' do
    context "with default redirect limit" do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp)
      end

      it "should follow 5 redirects" do
        @driver.visit("/redirect/5/times")
        @driver.html.should include('redirection complete')
      end

      it "should not follow more than 6 redirects" do
        expect do
          @driver.visit("/redirect/6/times")
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end

    context "with 21 redirect limit" do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp, :redirect_limit => 21)
      end

      it "should follow 21 redirects" do
        @driver.visit("/redirect/21/times")
        @driver.html.should include('redirection complete')
      end

      it "should not follow more than 21 redirects" do
        expect do
          @driver.visit("/redirect/22/times")
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end
  end
end
