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
        Capybara::RackTest::Driver.new(app)
      end
      session = Capybara::Session.new(:schmoo, TestApp)
      session.visit('/')
      session.body.should include("Hello world!")
    end
  end

  describe ".server" do
    after do
      Capybara.server {|app, port| Capybara.run_default_server(app, port)}
    end

    it "should default to a proc that calls run_default_server" do
      mock_app = mock('app')
      Capybara.should_receive(:run_default_server).with(mock_app, 8000)
      Capybara.server.call(mock_app, 8000)
    end

    it "should return a custom server proc" do
      server = lambda {|app, port|}
      Capybara.server(&server)
      Capybara.server.should == server
    end
  end
end

describe Capybara::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      expect {
        Capybara::Session.new(:quox, TestApp).driver
      }.to raise_error(Capybara::DriverNotFoundError)
    end
  end
end
