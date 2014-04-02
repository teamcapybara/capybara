Capybara::SpecHelper.spec '#save_page' do
  let(:alternative_path) { File.join(Dir.pwd, "save_and_open_page_tmp") }
  before do
    @session.visit("/foo")
  end

  after do
    Capybara.save_and_open_page_path = nil
    Dir.glob("capybara-*.html").each do |file|
      FileUtils.rm(file)
    end
    FileUtils.rm_rf alternative_path
  end

  it "saves the page in the root directory" do
    @session.save_page
    path = Dir.glob("capybara-*.html").first
    expect(File.read(path)).to include("Another World")
  end

  it "generates a sensible filename" do
    @session.save_page
    path = Dir.glob("capybara-*.html").first
    filename = path.split("/").last
    expect(filename).to match /^capybara-\d+\.html$/
  end

  it "can store files in a specified directory" do
    Capybara.save_and_open_page_path = alternative_path
    @session.save_page
    path = Dir.glob(alternative_path + "/capybara-*.html").first
    expect(File.read(path)).to include("Another World")
  end

  it "uses the given filename" do
    @session.save_page("capybara-001122.html")
    expect(File.read("capybara-001122.html")).to include("Another World")
  end

  it "returns an absolute path in pwd" do
    result = @session.save_page
    path = File.expand_path(Dir.glob("capybara-*.html").first, Dir.pwd)
    expect(result).to eq(path)
  end

  it "returns an absolute path in given directory" do
    Capybara.save_and_open_page_path = alternative_path
    result = @session.save_page
    path = File.expand_path(Dir.glob(alternative_path + "/capybara-*.html").first, alternative_path)
    expect(result).to eq(path)
  end

  context "asset_host contains a string" do
    before { Capybara.asset_host = "http://example.com" }
    after { Capybara.asset_host = nil }

    it "prepends base tag with value from asset_host to the head" do
      @session.visit("/with_js")
      path = @session.save_page

      result = File.read(path)
      expect(result).to include("<head><base href='http://example.com' />")
    end

    it "doesn't prepend base tag to pages when asset_host is nil" do
      Capybara.asset_host = nil
      @session.visit("/with_js")
      path = @session.save_page

      result = File.read(path)
      expect(result).not_to include("http://example.com")
    end

    it "doesn't prepend base tag to pages which already have it" do
      @session.visit("/with_base_tag")
      path = @session.save_page

      result = File.read(path)
      expect(result).not_to include("http://example.com")
    end
  end
end
