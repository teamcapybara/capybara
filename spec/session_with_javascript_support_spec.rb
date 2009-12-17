require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'nokogiri'

shared_examples_for "session with javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_js') }
    it "should return the evaluated script" do
      @session.evaluate_script("1+3").should == 4
    end
  end

  describe '#wait_for' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.wait_for("//a[contains(.,'Has been clicked')]")[:href].should == '#'
    end
  end

  describe '#click' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click('Has been clicked')
    end
  end

  describe '#click_link' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click_link('Has been clicked')
    end
  end
  
  describe '#click_button' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click_button('New Here')
    end
  end
  
  describe '#fill_in' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.fill_in('new_field', :with => 'Testing...')
    end
  end
  
end
