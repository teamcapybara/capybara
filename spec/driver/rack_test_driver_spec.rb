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

  describe '#visit' do
    it 'should not follow redirects to an external URL' do
      @driver.visit('/external_redirect')
      @driver.response_headers["Location"].should == 'http://www.google.com/'
    end
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

  describe ':external_redirects option' do
    it 'should allow external redirects to be followed' do
      @driver = Capybara::RackTest::Driver.new(TestApp, :follow_external_redirects => true)
      @driver.visit('/external_redirect')
      @driver.current_url.should == 'http://www.google.com/'
    end
  end
end
