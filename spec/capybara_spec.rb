# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara do
  describe 'default_max_wait_time' do
    after do
      Capybara.default_max_wait_time = @previous_default_time
    end

    it "should be changeable" do
      @previous_default_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 5
      expect(Capybara.default_max_wait_time).to eq(5)
    end

    it "should be accesible as the deprecated default_wait_time" do
      expect(Capybara).to receive(:warn).ordered.with('DEPRECATED: #default_wait_time= is deprecated, please use #default_max_wait_time= instead')
      expect(Capybara).to receive(:warn).ordered.with('DEPRECATED: #default_wait_time is deprecated, please use #default_max_wait_time instead')
      @previous_default_time = Capybara.default_max_wait_time
      Capybara.default_wait_time = 5
      expect(Capybara.default_wait_time).to eq(5)
      expect(Capybara.default_max_wait_time).to eq(5)
    end
  end

  describe '.register_driver' do
    it "should add a new driver" do
      Capybara.register_driver :schmoo do |app|
        Capybara::RackTest::Driver.new(app)
      end
      session = Capybara::Session.new(:schmoo, TestApp)
      session.visit('/')
      expect(session.body).to include("Hello world!")
    end
  end

  describe '.register_server' do
    before do
      Capybara.reuse_server = false
      @old_server = Capybara.server
    end

    after do
      Capybara.server(&@old_server)
      Capybara.reuse_server = true
    end

    it "should add a new server" do
      skip "JRuby fails this because of path issues to geckodriver I think. Its tested in other runs - not worth figuring out at this time" if RUBY_PLATFORM == 'java'

      require 'rack/handler/webrick'
      Capybara.register_server :blob do |app, port, host|
        Rack::Handler::WEBrick.run(app, Host: host, Port: port, AccessLog: [], Logger: WEBrick::Log::new(nil, 0))
      end
      Capybara.server = :blob
      session = Capybara::Session.new(:selenium, TestApp.new)
      session.visit('/')
      expect(session.body).to include("Hello world!")
    end
  end

  describe ".server" do
    before do
      @old_server = Capybara.server
    end

    after do
      Capybara.server(&@old_server)
    end

    it "should default to a proc that calls run_default_server" do
      mock_app = double('app')
      expect(Capybara).to receive(:run_default_server).with(mock_app, 8000)
      Capybara.server.call(mock_app, 8000)
    end

    it "should return a custom server proc" do
      server = lambda {|app, port|}
      Capybara.server(&server)
      expect(Capybara.server).to eq(server)
    end
  end

  describe 'app_host' do
    after do
      Capybara.app_host = nil
    end

    it "should warn if not a valid URL" do
      expect { Capybara.app_host = "www.example.com" }.to raise_error(ArgumentError, /Capybara\.app_host should be set to a url/)
    end

    it "should not warn if a valid URL" do
      expect { Capybara.app_host = "http://www.example.com" }.not_to raise_error
    end

    it "should not warn if nil" do
      expect { Capybara.app_host = nil }.not_to raise_error
    end
  end

  describe 'default_host' do
    around do |test|
      old_default = Capybara.default_host
      test.run
      Capybara.default_host = old_default
    end

    it "should warn if not a valid URL" do
      expect { Capybara.default_host = "www.example.com" }.to raise_error(ArgumentError, /Capybara\.default_host should be set to a url/)
    end

    it "should not warn if a valid URL" do
      expect { Capybara.default_host = "http://www.example.com" }.not_to raise_error
    end
  end
end

RSpec.describe Capybara::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      expect {
        Capybara::Session.new(:quox, TestApp).driver
      }.to raise_error(Capybara::DriverNotFoundError)
    end
  end
end
