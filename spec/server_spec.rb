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

  it "should wait specified time for the app to boot" do
    pending 'this test does not work: https://groups.google.com/d/msg/ruby-capybara/QrSKTbjh5rY/egvcVFYiWZMJ'

    @slow_app = proc { |env| sleep(1); [200, {}, "Hello Slow Server!"] }

    Capybara.server_boot_timeout = 1.5
    @server = Capybara::Server.new(@slow_app).boot

    @res = Net::HTTP.start(@server.host, @server.port) { |http| http.get('/') }
    @res.body.should include('Hello Slow Server')
  end

  it "should raise an exception if boot timeout is exceeded" do
    pending 'this test does not work: https://groups.google.com/d/msg/ruby-capybara/QrSKTbjh5rY/egvcVFYiWZMJ'

    @slow_app = proc { |env| sleep(1); [200, {}, "Hello Slow Server!"] }

    Capybara.server_boot_timeout = 0.5
    server = Capybara::Server.new(@slow_app)
    server.stub(:exit).and_return(:timeout)
    server.stub(:puts)
    server.boot.should == :timeout
  end

end
