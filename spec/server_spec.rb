require 'spec_helper'

describe Capybara::Server do

  it "should spool up a rack server" do
    @app = proc { |env| [200, {}, "Hello Server!"]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, @server.port) { |http| http.get('/') }

    @res.body.should include('Hello Server')
  end

  it "should do nothing when no server given" do
    running do
      @server = Capybara::Server.new(nil).boot
    end.should_not raise_error
  end

  it "should bind to the specified host" do
    Capybara.server_host = '0.0.0.0'

    app = proc { |env| [200, {}, "Hello Server!"]}
    server = Capybara::Server.new(app).boot
    server.host.should == '0.0.0.0'

    Capybara.server_host = nil
  end

  it "should use specified port" do
    Capybara.server_port = 22789

    @app = proc { |env| [200, {}, "Hello Server!"]}
    @server = Capybara::Server.new(@app).boot

    @res = Net::HTTP.start(@server.host, 22789) { |http| http.get('/') }
    @res.body.should include('Hello Server')

    Capybara.server_port = nil
  end

  it "should find an available port" do
    @app1 = proc { |env| [200, {}, "Hello Server!"]}
    @app2 = proc { |env| [200, {}, "Hello Second Server!"]}

    @server1 = Capybara::Server.new(@app1).boot
    @server2 = Capybara::Server.new(@app2).boot

    @res1 = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
    @res1.body.should include('Hello Server')

    @res2 = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
    @res2.body.should include('Hello Second Server')
  end

  it "should use the server if it already running" do
    @app1 = proc { |env| [200, {}, "Hello Server!"]}
    @app2 = proc { |env| [200, {}, "Hello Second Server!"]}

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

  describe "should generate url with host/post of capybara server" do
    before do
      @app = proc { |env| [200, {}, "Hello Server!"]}
      @server = Capybara::Server.new(@app).boot
    end

    specify "without app_host" do
      Capybara.app_host = nil
      @server.url("/").should == "http://127.0.0.1:/"
      @server.stub(:port => 8080)
      @server.url("/").should == "http://127.0.0.1:8080/"
    end

    specify "with app_host" do
      Capybara.app_host = "http://www.example.com"
      @server.url("/").should == "http://www.example.com/"
      @server.stub(:port => 8080)
      @server.url("/").should == "http://www.example.com/"
    end

    specify "with app_host and use_own_port" do
      Capybara.app_host = "http://www.example.com"
      Capybara.use_own_port = true
      @server.stub(:port => 8080)
      @server.url("/").should == "http://www.example.com:8080/"
      @server.url("http://www.example.com").should == "http://www.example.com:8080"
      @server.url("http://www.example.com/").should == "http://www.example.com:8080/"
      @server.url("https://www.example.com/something").should == "https://www.example.com:8080/something"
      @server.url("http://www.example.com:7777/").should == "http://www.example.com:7777/"

      Capybara.app_host = "http://127.0.0.1"
      @server.url("/").should == "http://127.0.0.1:8080/"
      @server.url("/something").should == "http://127.0.0.1:8080/something"
      @server.url("https://127.0.0.1/something").should == "https://127.0.0.1:8080/something"
    end

    after do
      Capybara.use_own_port = false
      Capybara.app_host = nil
    end
  end
end
