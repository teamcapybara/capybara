# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Server do

  it "should spool up a rack server" do
    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, @server.port) { |http| http.get('/') }

    expect(@res.body).to include('Hello Server')
  end

  it "should do nothing when no server given" do
    expect do
      @server = Capybara::Server.new(nil).boot
    end.not_to raise_error
  end

  it "should bind to the specified host" do
    begin
      app = proc { |env| [200, {}, ['Hello Server!']] }

      Capybara.server_host = '127.0.0.1'
      server = Capybara::Server.new(app).boot
      res = Net::HTTP.get(URI("http://127.0.0.1:#{server.port}"))
      expect(res).to eq('Hello Server!')

      Capybara.server_host = '0.0.0.0'
      server = Capybara::Server.new(app).boot
      res = Net::HTTP.get(URI("http://127.0.0.1:#{server.port}"))
      expect(res).to eq('Hello Server!')
    ensure
      Capybara.server_host = nil
    end
  end unless ENV['TRAVIS'] and (RUBY_ENGINE == 'jruby') #TODO travis with jruby in container mode has an issue with this test

  it "should use specified port" do
    Capybara.server_port = 22789

    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, 22789) { |http| http.get('/') }
    expect(@res.body).to include('Hello Server')

    Capybara.server_port = nil
  end

  it "should use given port" do
    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app, 22790).boot

    @res = Net::HTTP.start(@server.host, 22790) { |http| http.get('/') }
    expect(@res.body).to include('Hello Server')

    Capybara.server_port = nil
  end

  it "should find an available port" do
    @app1 = proc { |env| [200, {}, ["Hello Server!"]]}
    @app2 = proc { |env| [200, {}, ["Hello Second Server!"]]}

    @server1 = Capybara::Server.new(@app1).boot
    @server2 = Capybara::Server.new(@app2).boot

    @res1 = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
    expect(@res1.body).to include('Hello Server')

    @res2 = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
    expect(@res2.body).to include('Hello Second Server')
  end

  context "When Capybara.reuse_server is true" do
    before do
      @old_reuse_server = Capybara.reuse_server
      Capybara.reuse_server = true
    end

    after do
      Capybara.reuse_server = @old_reuse_server
    end

    it "should use the existing server if it already running" do
      @app = proc { |env| [200, {}, ["Hello Server!"]]}

      @server1 = Capybara::Server.new(@app).boot
      @server2 = Capybara::Server.new(@app).boot

      res = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
      expect(res.body).to include('Hello Server')

      res = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
      expect(res.body).to include('Hello Server')

      expect(@server1.port).to eq(@server2.port)
    end

    it "detects and waits for all reused server sessions pending requests" do
      done = false

      app = proc do |env|
        request = Rack::Request.new(env)
        sleep request.params['wait_time'].to_f
        done = true
        [200, {}, ["Hello Server!"]]
      end

      server1 = Capybara::Server.new(app).boot
      server2 = Capybara::Server.new(app).boot

      start_request(server1, 0.5)
      start_request(server2, 1.0)

      expect {
        server1.wait_for_pending_requests
      }.to change{done}.from(false).to(true)
      expect(server2.send(:pending_requests?)).to eq(false)
    end

  end

  context "When Capybara.reuse_server is false" do
    before do
      @old_reuse_server = Capybara.reuse_server
      Capybara.reuse_server = false
    end

    after do
      Capybara.reuse_server = @old_reuse_server
    end

    it "should not reuse an already running server" do
      @app = proc { |env| [200, {}, ["Hello Server!"]]}

      @server1 = Capybara::Server.new(@app).boot
      @server2 = Capybara::Server.new(@app).boot

      res = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
      expect(res.body).to include('Hello Server')

      res = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
      expect(res.body).to include('Hello Server')

      expect(@server1.port).not_to eq(@server2.port)
    end

    it "detects and waits for only one sessions pending requests" do
      done = false

      app = proc do |env|
        request = Rack::Request.new(env)
        sleep request.params['wait_time'].to_f
        done = true
        [200, {}, ["Hello Server!"]]
      end

      server1 = Capybara::Server.new(app).boot
      server2 = Capybara::Server.new(app).boot

      start_request(server1, 0.5)
      start_request(server2, 1.0)

      expect {
        server1.wait_for_pending_requests
      }.to change{done}.from(false).to(true)
      expect(server2.send(:pending_requests?)).to eq(true)
    end

  end

  it "should raise server errors when the server errors before the timeout" do
    begin
      Capybara.register_server :kaboom do
        sleep 0.1
        raise 'kaboom'
      end
      Capybara.server = :kaboom

      expect do
        Capybara::Server.new(proc {|e|}).boot
      end.to raise_error(RuntimeError, 'kaboom')
    ensure
      # TODO refactor out the defaults so it's reliant on unset state instead of
      # a one-time call in capybara.rb
      Capybara.server = :default
    end
  end

  it "is not #responsive? when Net::HTTP raises a SystemCallError" do
    app = lambda { [200, {}, ['Hello, world']] }
    server = Capybara::Server.new(app)
    expect(Net::HTTP).to receive(:start).and_raise(SystemCallError.allocate)
    expect(server.responsive?).to eq false
  end

  def start_request(server, wait_time)
    # Start request, but don't wait for it to finish
    socket = TCPSocket.new(server.host, server.port)
    socket.write "GET /?wait_time=#{wait_time.to_s} HTTP/1.0\r\n\r\n"
    socket.close
    sleep 0.1
  end
end
