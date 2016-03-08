# frozen_string_literal: true
require "capybara/spec/test_app"

Capybara::SpecHelper.spec '#current_url, #current_path, #current_host' do
  before :all do
    @servers = 2.times.map { Capybara::Server.new(TestApp.clone).boot }
    # sanity check
    expect(@servers[0].port).not_to eq(@servers[1].port)
    expect(@servers.map { |s| s.port }).not_to include 80
  end

  def bases
    @servers.map { |s| "http://#{s.host}:#{s.port}" }
  end

  def should_be_on server_index, path="/host", scheme="http"
    #This delay is to give fully async drivers (selenium w/chromedriver) time for the browser
    #to get to its destination - should be removed when we have a waiting current_url matcher
    sleep 0.1  # remove and adjust tests when a waiting current_url/path matcher is implemented
    # Check that we are on /host on the given server
    s = @servers[server_index]
    expect(@session.current_url.chomp('?')).to eq("#{scheme}://#{s.host}:#{s.port}#{path}")
    expect(@session.current_host).to eq("#{scheme}://#{s.host}") # no port
    expect(@session.current_path).to eq(path)
    if path == '/host'
      # Server should agree with us
      expect(@session).to have_content("Current host is #{scheme}://#{s.host}:#{s.port}")
    end
  end

  def visit_host_links
    @session.visit("#{bases[0]}/host_links?absolute_host=#{bases[1]}")
  end

  it "is affected by visiting a page directly" do
    @session.visit("#{bases[0]}/host")
    should_be_on 0
  end

  it "returns to the app host when visiting a relative url" do
    Capybara.app_host = bases[1]
    @session.visit("#{bases[0]}/host")
    should_be_on 0
    @session.visit('/host')
    should_be_on 1
    Capybara.app_host = nil
  end

  it "is affected by setting Capybara.app_host" do
    Capybara.app_host = bases[0]
    @session.visit("/host")
    should_be_on 0
    Capybara.app_host = bases[1]
    @session.visit("/host")
    should_be_on 1
    Capybara.app_host = nil
  end

  it "is unaffected by following a relative link" do
    visit_host_links
    @session.click_link("Relative Host")
    should_be_on 0
  end

  it "is affected by following an absolute link" do
    visit_host_links
    @session.click_link("Absolute Host")
    should_be_on 1
  end

  it "is unaffected by posting through a relative form" do
    visit_host_links
    @session.click_button("Relative Host")
    should_be_on 0
  end

  it "is affected by posting through an absolute form" do
    visit_host_links
    @session.click_button("Absolute Host")
    should_be_on 1
  end

  it "is affected by following a redirect" do
    @session.visit("#{bases[0]}/redirect")
    should_be_on 0, "/landed"
  end

  it "is affected by pushState", :requires => [:js] do
    @session.visit("/with_js")
    @session.execute_script("window.history.pushState({}, '', '/pushed')")
    expect(@session.current_path).to eq("/pushed")
  end

  it "is affected by replaceState", :requires => [:js] do
    @session.visit("/with_js")
    @session.execute_script("window.history.replaceState({}, '', '/replaced')")
    expect(@session.current_path).to eq("/replaced")
  end
end
