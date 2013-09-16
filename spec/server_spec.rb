require 'spec_helper'

describe Capybara::Server do

  it "should spool up a rack server" do
    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, @server.port) { |http| http.get('/') }

    @res.body.should include('Hello Server')
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
  end

  it "should use specified port" do
    Capybara.server_port = 22789

    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, 22789) { |http| http.get('/') }
    @res.body.should include('Hello Server')

    Capybara.server_port = nil
  end

  it "should use given port" do
    @app = proc { |env| [200, {}, ["Hello Server!"]]}
    @server = Capybara::Server.new(@app, 22790).boot

    @res = Net::HTTP.start(@server.host, 22790) { |http| http.get('/') }
    @res.body.should include('Hello Server')

    Capybara.server_port = nil
  end

  it "should find an available port" do
    @app1 = proc { |env| [200, {}, ["Hello Server!"]]}
    @app2 = proc { |env| [200, {}, ["Hello Second Server!"]]}

    @server1 = Capybara::Server.new(@app1).boot
    @server2 = Capybara::Server.new(@app2).boot

    @res1 = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
    @res1.body.should include('Hello Server')

    @res2 = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
    @res2.body.should include('Hello Second Server')
  end

  it "should use the server if it already running" do
    @app1 = proc { |env| [200, {}, ["Hello Server!"]]}
    @app2 = proc { |env| [200, {}, ["Hello Second Server!"]]}

    @server1a = Capybara::Server.new(@app1).boot
    @server1b = Capybara::Server.new(@app1).boot
    @server2a = Capybara::Server.new(@app2).boot
    @server2b = Capybara::Server.new(@app2).boot

    @res1 = Net::HTTP.start(@server1b.host, @server1b.port) { |http| http.get('/') }
    @res1.body.should include('Hello Server')

    @res2 = Net::HTTP.start(@server2b.host, @server2b.port) { |http| http.get('/') }
    @res2.body.should include('Hello Second Server')

    @server1a.port.should == @server1b.port
    @server2a.port.should == @server2b.port
  end

  it "should raise server errors when the server errors before the timeout" do
    begin
      Capybara.server do
        sleep 0.1
        raise 'kaboom'
      end

      proc do
        Capybara::Server.new(proc {|e|}).boot
      end.should raise_error(RuntimeError, 'kaboom')
    ensure
      # TODO refactor out the defaults so it's reliant on unset state instead of
      # a one-time call in capybara.rb
      Capybara.server {|app, port| Capybara.run_default_server(app, port)}
    end
  end

  it "is not #responsive? when Net::HTTP raises a SystemCallError" do
    app = lambda { [200, {}, ['Hello, world']] }
    server = Capybara::Server.new(app)
    Net::HTTP.should_receive(:start).and_raise(SystemCallError.allocate)
    expect(server.responsive?).to eq false
  end
end
