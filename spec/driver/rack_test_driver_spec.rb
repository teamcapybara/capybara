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

describe Capybara::Driver::RackTest do
  before do
    @driver = TestSessions::RackTest.driver
  end

  it "should throw an error when no rack app is given" do
    running do
      Capybara::Driver::RackTest.new(nil)
    end.should raise_error(ArgumentError)
  end

  if '1.9'.respond_to?(:encode)
    describe "with non-binary parameters" do

      it "should convert attribute values to binary" do
        output = capture(:stderr) {
          @driver.visit('/mypage', :param => 'µ')
        }.should_not =~ %r{warning: regexp match /.../n against to UTF-8 string}
      end

      it "should convert attribute with Array to binary" do
        output = capture(:stderr) {
          @driver.visit('/mypage', :param => ['µ'])
        }.should_not =~ %r{warning: regexp match /.../n against to UTF-8 string}
      end

      it "should convert path to binary" do
        output = capture(:stderr) {
          @driver.visit('/mypage'.encode('utf-8'))
        }.should_not =~ %r{warning: regexp match /.../n against to UTF-8 string}
      end
    end
  end

  describe "Capybara.app_host" do
    after(:all) { Capybara.app_host = nil } # reset app_host back to nil

    describe "set to custom host" do
      before { Capybara.app_host = 'http://foo.example.com' }

      it "should prefix urls with Capybara.app_host if app_host is set" do
        @driver.visit('/')
        @driver.last_request.url.should == 'http://foo.example.com/'
      end

      it "forms should POST to Capybara.app_host" do
        @driver.visit('/form')
        @driver.last_request.url.should == 'http://foo.example.com/form'

        # click button that does a POST to "/form"
        @driver.find('//input[@id="awe123"]').first.click
        @driver.last_request.url.should == 'http://foo.example.com/form'
      end
    end

    describe "set to nil" do
      before { Capybara.app_host = nil }

      it "should not prefix urls with Capybara.app_host" do
        @driver.visit('/')
        @driver.last_request.url.should == 'http://www.example.com/'
      end

      it "forms should POST normally" do
        @driver.visit('/form')
        @driver.last_request.url.should == 'http://www.example.com/form'

        # click button that does a POST to "/form"
        @driver.find('//input[@id="awe123"]').first.click
        @driver.last_request.url.should == 'http://www.example.com/form'
      end
    end
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with infinite redirect detection"
end
