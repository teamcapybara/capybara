# encoding: utf-8
require 'spec_helper'
require 'stringio'

describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::RackTest.driver
  end

  it "should throw an error when no rack app is given" do
    running do
      Capybara::RackTest::Driver.new(nil)
    end.should raise_error(ArgumentError)
  end

  describe '#reset!' do
    it { @driver.visit('/foo'); lambda { @driver.reset! }.should change(@driver, :current_url).to('') }

    it 'should reset headers' do
      @driver.header('FOO', 'BAR')
      @driver.visit('/get_header')
      @driver.body.should include('BAR')

      @driver.reset!
      @driver.visit('/get_header')
      @driver.body.should_not include('BAR')
    end

    it 'should reset response' do
      @driver.visit('/foo')
      lambda { @driver.response }.should_not raise_error
      @driver.reset!
      lambda { @driver.response }.should raise_error
    end

    it 'should request response' do
      @driver.visit('/foo')
      lambda { @driver.request }.should_not raise_error
      @driver.reset!
      lambda { @driver.request }.should raise_error
    end
  end

  describe ':headers option' do
    it 'should always set headers' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header')
      @driver.body.should include('foobar')
    end

    it 'should keep headers on link clicks' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find('.//a').first.click
      @driver.body.should include('foobar')
    end

    it 'should keep headers on form submit' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/header_links')
      @driver.find('.//input').first.click
      @driver.body.should include('foobar')
    end

    it 'should keep headers on redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      @driver.visit('/get_header_via_redirect')
      @driver.body.should include('foobar')
    end
  end

  describe ':follow_redirects option' do
    it "defaults to following redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp)

      @driver.visit('/redirect')
      @driver.response.header['Location'].should be_nil
      @driver.browser.current_url.should eq "#{@driver.browser.current_host}/landed"
    end

    it "is possible to not follow redirects" do
      @driver = Capybara::RackTest::Driver.new(TestApp, :follow_redirects => false)

      @driver.visit('/redirect')
      @driver.response.header['Location'].should eq "#{@driver.browser.current_host}/redirect_again"
      @driver.browser.current_url.should eq "#{@driver.browser.current_host}/redirect"
    end
  end

  describe ':redirect_limit option' do
    context "with default redirect limit" do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp)
      end

      it "should follow 5 redirects" do
        @driver.visit("/redirect/5/times")
        @driver.body.should include('redirection complete')
      end

      it "should not follow more than 6 redirects" do
        running do
          @driver.visit("/redirect/6/times")
        end.should raise_error(Capybara::InfiniteRedirectError)
      end
    end

    context "with 21 redirect limit" do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp, :redirect_limit => 21)
      end

      it "should follow 21 redirects" do
        @driver.visit("/redirect/21/times")
        @driver.body.should include('redirection complete')
      end

      it "should not follow more than 21 redirects" do
        running do
          @driver.visit("/redirect/22/times")
        end.should raise_error(Capybara::InfiniteRedirectError)
      end
    end
  end
end
