require 'spec_helper'

describe Capybara do

  describe 'default_wait_time' do
    after do
      Capybara.default_wait_time = @previous_default_time
    end

    it "should be changeable" do
      @previous_default_time = Capybara.default_wait_time
      Capybara.default_wait_time = 5
      Capybara.default_wait_time.should == 5
    end
  end

  describe '.register_driver' do
    it "should add a new driver" do
      Capybara.register_driver :schmoo do |app|
        Capybara::Driver::RackTest.new(app)
      end
      session = Capybara::Session.new(:schmoo, TestApp)
      session.visit('/')
      session.body.should include("Hello world!")
    end
  end

end
