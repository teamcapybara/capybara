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

  it "should use the server if it already running" do
    @app1 = proc { |env| [200, {}, ["Hello Server!"]]}
    @app2 = proc { |env| [200, {}, ["Hello Second Server!"]]}

    @server1a = Capybara::Server.new(@app1).boot
    @server1b = Capybara::Server.new(@app1).boot
    @server2a = Capybara::Server.new(@app2).boot
    @server2b = Capybara::Server.new(@app2).boot

    @res1 = Net::HTTP.start(@server1b.host, @server1b.port) { |http| http.get('/') }
    expect(@res1.body).to include('Hello Server')

    @res2 = Net::HTTP.start(@server2b.host, @server2b.port) { |http| http.get('/') }
    expect(@res2.body).to include('Hello Second Server')

    expect(@server1a.port).to eq(@server1b.port)
    expect(@server2a.port).to eq(@server2b.port)
  end

  it "should raise server errors when the server errors before the timeout" do
    begin
      Capybara.server do
        sleep 0.1
        raise 'kaboom'
      end

      expect do
        Capybara::Server.new(proc {|e|}).boot
      end.to raise_error(RuntimeError, 'kaboom')
    ensure
      # TODO refactor out the defaults so it's reliant on unset state instead of
      # a one-time call in capybara.rb
      Capybara.server {|app, port| Capybara.run_default_server(app, port)}
    end
  end

  it "is not #responsive? when Net::HTTP raises a SystemCallError" do
    app = lambda { [200, {}, ['Hello, world']] }
    server = Capybara::Server.new(app)
    expect(Net::HTTP).to receive(:start).and_raise(SystemCallError.allocate)
    expect(server.responsive?).to eq false
  end

  it "can detect and wait for pending requests" do
    done = false
    app = proc do |env|
      sleep 0.2
      done = true
      [200, {}, ["Hello Server!"]]
    end
    server = Capybara::Server.new(app).boot

    # Start request, but don't wait for it to finish
    socket = TCPSocket.new(server.host, server.port)
    socket.write "GET / HTTP/1.0\r\n\r\n"
    socket.close
    sleep 0.1

    expect(done).to be false

    server.wait_for_pending_requests

    # Ensure server was allowed to finish
    expect(done).to be true
  end
end
