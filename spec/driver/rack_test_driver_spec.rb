# encoding: utf-8
require 'spec_helper'
require 'stringio'

def capture(*streams)
  streams.map! { |stream| stream.to_s }
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
  end
  result.string
end

describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::RackTest.driver
  end

  it "should throw an error when no rack app is given" do
    running do
      Capybara::RackTest::Driver.new(nil)
    end.should raise_error(ArgumentError)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with infinite redirect detection"

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
  end

  describe "manual cookie setting" do
    before do
      # Use different driver instance in order to not interfere with the other tests
      @driver = Capybara::Session.new(:rack_test, TestApp).driver
    end

    it "should allow a cookie to be manually set" do
      @driver.browser.set_cookie 'capybara=test_cookie'

      @driver.visit('/get_cookie')
      @driver.body.should include('test_cookie')
    end

    describe "cookies with a custom Capybara.app_host" do
      before { Capybara.app_host = 'http://foo.com' }
      after  { Capybara.app_host = nil              }

      it "should allow a cookie to be manually set" do
        @driver.browser.set_cookie 'capybara=test_cookie'

        @driver.visit('/get_cookie')
        @driver.body.should include('test_cookie')
      end

      it "should allow a cookie to be manually set with a different current host" do
        @driver.browser.current_host = 'http://foobar.com'
        @driver.browser.set_cookie 'capybara=test_cookie'

        @driver.visit('http://foobar.com/get_cookie')
        @driver.body.should include('test_cookie')
      end
    end
  end
end
