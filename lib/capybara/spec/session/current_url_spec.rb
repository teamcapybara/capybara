Capybara::SpecHelper.spec '#current_url, #current_path, #current_host, #current_path_query' do
  before :all do
    @servers = 2.times.map { Capybara::Server.new(TestApp.clone).boot }
    # sanity check
    expect(@servers[0].port).not_to eq(@servers[1].port)
    expect(@servers.map { |s| s.port }).not_to include 80
  end

  def bases
    @servers.map { |s| "http://#{s.host}:#{s.port}" }
  end

  def should_be_on server_index, path="/host", query="query=test", scheme="http"
    # Check that we are on /host on the given server
    s = @servers[server_index]
    expect(@session.current_host).to eq("#{scheme}://#{s.host}") # no port
    expect(@session.current_path).to eq(path)
    if query.empty?
      expect(@session.current_url.chomp('?')).to eq("#{scheme}://#{s.host}:#{s.port}#{path}")
      expect(@session.current_path_query).to eq(path)
    else
      expect(@session.current_url.chomp('?')).to eq("#{scheme}://#{s.host}:#{s.port}#{path}?#{query}")
      expect(@session.current_path_query).to include(path, query)
    end
    if path == '/host'
      # Server should agree with us
      expect(@session).to have_content("Current host is #{scheme}://#{s.host}:#{s.port}")
    end
  end

  def visit_host_links
    @session.visit("#{bases[0]}/host_links?absolute_host=#{bases[1]}&query=test")
  end

  it "is affected by visiting a page directly" do
    @session.visit("#{bases[0]}/host?query=test")
    should_be_on 0
  end

  it "returns to the app host when visiting a relative url" do
    Capybara.app_host = bases[1]
    @session.visit("#{bases[0]}/host?query=test")
    should_be_on 0
    @session.visit('/host?query=test')
    should_be_on 1
    Capybara.app_host = nil
  end

  it "is affected by setting Capybara.app_host" do
    Capybara.app_host = bases[0]
    @session.visit("/host?query=test")
    should_be_on 0
    Capybara.app_host = bases[1]
    @session.visit("/host?query=test")
    should_be_on 1
    Capybara.app_host = nil
  end

  it "is unaffected by following a relative link" do
    visit_host_links
    @session.click_link("Relative Host")
    should_be_on 0, "/host", ""
  end

  it "is affected by following an absolute link" do
    visit_host_links
    @session.click_link("Absolute Host")
    should_be_on 1, "/host", ""
  end

  it "is unaffected by posting through a relative form" do
    visit_host_links
    @session.click_button("Relative Host")
    should_be_on 0, "/host", ""
  end

  it "is affected by posting through an absolute form" do
    visit_host_links
    @session.click_button("Absolute Host")
    should_be_on 1, "/host", ""
  end

  it "is affected by following a redirect" do
    @session.visit("#{bases[0]}/redirect")
    should_be_on 0, "/landed", ""
  end

  it "is affected by pushState", :requires => [:js] do
    @session.visit("/with_js")
    @session.execute_script("window.history.pushState({}, '', '/pushed?query=test')")
    expect(@session.current_path).to eq("/pushed")
    expect(@session.current_path_query).to eq("/pushed?query=test")
  end

  it "is affected by replaceState", :requires => [:js] do
    @session.visit("/with_js")
    @session.execute_script("window.history.replaceState({}, '', '/replaced?query=test')")
    expect(@session.current_path).to eq("/replaced")
    expect(@session.current_path_query).to eq("/replaced?query=test")
  end
end
