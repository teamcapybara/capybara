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
      expect(Capybara.send(:config)).to receive(:warn).ordered.with('DEPRECATED: #default_wait_time= is deprecated, please use #default_max_wait_time= instead')
      expect(Capybara.send(:config)).to receive(:warn).ordered.with('DEPRECATED: #default_wait_time is deprecated, please use #default_max_wait_time instead')
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
    it "should add a new server" do
      handler = double("handler")
      Capybara.register_server :blob do |app, port, host|
        handler.run
      end

      expect(Capybara.servers).to have_key(:blob)
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

    it "should have :webrick registered" do
      require 'rack/handler/webrick'
      mock_app = double('app')
      Capybara.server = :webrick
      expect(Rack::Handler::WEBrick).to receive(:run)
      Capybara.server.call(mock_app, 8000)
    end

    it "should have :puma registered" do
      require 'rack/handler/puma'
      mock_app = double('app')
      Capybara.server = :puma
      expect(Rack::Handler::Puma).to receive(:run).with(mock_app, hash_including(Host: nil, Port: 8000))
      Capybara.server.call(mock_app, 8000)
    end

    it "should pass options to server" do
      require 'rack/handler/puma'
      mock_app = double('app')
      Capybara.server = :puma, { Silent: true }
      expect(Rack::Handler::Puma).to receive(:run).with(mock_app, hash_including(Host: nil, Port: 9000, Silent: true))
      Capybara.server.call(mock_app, 9000)
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

  describe "configure" do
    it 'deprecates calling non configuration option methods in configure' do
      expect_any_instance_of(Kernel).to receive(:warn).
        with('Calling register_driver from Capybara.configure is deprecated - please call it on Capybara directly ( Capybara.register_driver(...) )')
      Capybara.configure do |config|
        config.register_driver(:random_name) do
          #just a random block
        end
      end
    end
  end
end

RSpec.describe Capybara::Session do
  context 'with nonexistent driver' do
    it "should raise an error" do
      expect {
        Capybara::Session.new(:quox, TestApp).driver
      }.to raise_error(Capybara::DriverNotFoundError)
    end
  end
end
