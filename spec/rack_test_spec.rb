require 'spec_helper'

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::RackTest, "RackTest", :capybara_skip => [
  :js,
  :modals,
  :screenshot,
  :frames,
  :windows,
  :server,
  :hover
]

RSpec.describe Capybara::Session do
  context 'with rack test driver' do
    before do
      @session = TestSessions::RackTest
    end

    describe '#driver' do
      it "should be a rack test driver" do
        expect(@session.driver).to be_an_instance_of(Capybara::RackTest::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        expect(@session.mode).to eq(:rack_test)
      end
    end

    describe '#click_link' do
      it "should use data-method if option is true" do
        @session.driver.options[:respect_data_method] = true
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        expect(@session.html).to include('The requested object was deleted')
      end

      it "should not use data-method if option is false" do
        @session.driver.options[:respect_data_method] = false
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        expect(@session.html).to include('Not deleted')
      end

      it "should use data-method if available even if it's capitalized" do
        @session.driver.options[:respect_data_method] = true
        @session.visit "/with_html"
        @session.click_link "A link with capitalized data-method"
        expect(@session.html).to include('The requested object was deleted')
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
          expect(@session.html).to include('Successfully ignored empty file field.')
        end
      end
    end
  end
end

RSpec.describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::RackTest.driver
  end

  describe ':headers option' do
    it 'should always set headers' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header')
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on link clicks' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find_xpath('.//a').first.click
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on form submit' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find_xpath('.//input').first.click
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header_via_redirect')
      expect(@driver.html).to include('foobar')
    end
  end

  describe ':follow_redirects option' do
    it "defaults to following redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp)

      @driver.visit('/redirect')
      expect(@driver.response.header['Location']).to be_nil
      expect(@driver.browser.current_url).to match %r{/landed$}
    end

    it "is possible to not follow redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp, :follow_redirects => false)

      @driver.visit('/redirect')
      expect(@driver.response.header['Location']).to match %r{/redirect_again$}
      expect(@driver.browser.current_url).to match %r{/redirect$}
    end
  end

  describe ':redirect_limit option' do
    context "with default redirect limit" do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp)
      end

      it "should follow 5 redirects" do
        @driver.visit("/redirect/5/times")
        expect(@driver.html).to include('redirection complete')
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
        expect(@driver.html).to include('redirection complete')
      end

      it "should not follow more than 21 redirects" do
        expect do
          @driver.visit("/redirect/22/times")
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end
  end
end

module CSSHandlerIncludeTester
  def dont_extend_css_handler
    raise 'should never be called'
  end
end
include CSSHandlerIncludeTester

RSpec.describe  Capybara::RackTest::CSSHandlers do  
  it "should not be extended by global includes" do
    expect(Capybara::RackTest::CSSHandlers.new).not_to respond_to(:dont_extend_css_handler)
  end
end
  
