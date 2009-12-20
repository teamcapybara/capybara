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
  
  describe '#wait_for_condition' do
    it "should wait for condition to be true" do
      @session.visit('/with_js')
      @session.select('My Waiting Option', :from => 'waiter')
      @session.evaluate_script('activeRequests == 1').should be_true
      @session.wait_for_condition('activeRequests == 0').should be_true
      @session.evaluate_script('activeRequests == 0').should be_true
    end
    
    it "should timeout" do
      @session.visit('/with_js')
      @session.select('Timeout', :from => 'timeout')
      @session.evaluate_script('activeRequests == 1').should be_true
      @session.wait_for_condition('activeRequests == 0').should be_false
      @session.evaluate_script('activeRequests == 0').should be_false
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
