require 'spec_helper'

require 'capybara/util/save_and_open_page'
require 'launchy'
describe Capybara do

  describe ".save_and_open_page" do
    before do
      @name = 'tmp/capybara-test.html'
      @html = <<-HTML
        <html>
          <head>

          </head>
        </html>
      HTML
    end

    it "should open the file in the browser" do
      Capybara.should_receive(:save_page).and_return(@name)
      Capybara.should_receive(:open_in_browser).with(@name)
      Capybara.save_and_open_page(@html)
    end
  end

  describe ".save_page" do
    before do
      @time = Time.new.strftime("%Y%m%d%H%M%S")

      @temp_file = mock("FILE")
      @temp_file.stub!(:write)
      @temp_file.stub!(:close)

      @html = <<-HTML
        <html>
          <head>
            <script type="text/javascript" src="/javascripts/prototype.js?123"/>
          </head>
          <body>
            <h1>test</h1>
            <p>
              Some images (note differing whitespace closing tag):
              <img src="/images/image1.jpeg" />
              <img src="/images/image2.jpeg"/>
            </p>
            <p>
              Some more in a non-existent directory:
              <img src="/img/image3.jpeg" />
              <img src="/img/image4.jpeg"/>
            </p>
            <p>
              <a href="/not-here/foo.html">
                A link to a file in a non-existent directory.
              </a>
            </p>
          </body>
        <html>
      HTML

      Launchy::Browser.stub(:run)
    end

    def default_file_expectations
      @name = "capybara-#{@time}.html"

      @temp_file.stub!(:path).and_return(@name)

      File.should_receive(:exist?).and_return true
      File.should_receive(:new).and_return @temp_file
    end

    describe "defaults" do
      before do
        default_file_expectations
      end

      it "should create a new temporary file" do
        @temp_file.should_receive(:write).with @html
        Capybara.save_page @html
      end

      it "should open the file in the browser" do
        Capybara.save_page(@html).should == @name
      end
    end

    describe "custom output path" do
      before do
        @custom_path = File.join('tmp', 'capybara')
        @custom_name = File.join(@custom_path, "capybara-#{@time}.html")

        @temp_file.stub!(:path).and_return(@custom_name)

        Capybara.should_receive(:save_and_open_page_path).at_least(:once).and_return(@custom_path)
      end

      it "should create a new temporary file in the custom path" do
        File.should_receive(:directory?).and_return true
        File.should_receive(:exist?).and_return true
        File.should_receive(:new).and_return @temp_file

        @temp_file.should_receive(:write).with @html
        Capybara.save_page @html
      end

      it "should return the path to the file - in the custom path" do
        Capybara.save_page(@html).should == @custom_name
      end

      it "should be possible to configure output path" do
        Capybara.should respond_to(:save_and_open_page_path)
        default_setting = Capybara.save_and_open_page_path
        lambda {
            Capybara.save_and_open_page_path = File.join('tmp', 'capybara')
            Capybara.save_and_open_page_path.should == File.join('tmp', 'capybara')
          }.should_not raise_error
        Capybara.save_and_open_page_path = default_setting
      end
    end

    describe "custom file name" do
      before do
        @custom_name = 'cucumber-scenario.html'
        @temp_file.stub!(:path).and_return(@custom_name)
        @save_page_path = File.join('tmp','capybara')
        Capybara.should_receive(:save_and_open_page_path).
          at_least(:once).
          and_return(@save_page_path)

        File.should_receive(:new).and_return @temp_file
      end

      it "should use the passed argument as file name" do
        File.should_receive(:exist?).with(File.join @save_page_path, @custom_name).and_return true

        Capybara.save_page(@html, @custom_name)
      end
    end

    describe "rewrite_css_and_image_references" do
      before do
        default_file_expectations
        @asset_root_dir = "/path/to/rails/public"
      end

      def mock_asset_root_with(directories)
        @asset_root = Pathname.new(@asset_root_dir)
        Capybara.should_receive(:asset_root).and_return @asset_root

        dir = mock('asset_root mock dir')
        Dir.should_receive(:new).with(@asset_root).and_return dir

        dirents = [ '.', '..', 'file.html' ] + directories
        dir.should_receive(:entries).and_return dirents

        directories_regexp = directories.join('|')
        FileTest.should_receive(:directory?) \
                .at_least(dirents.size - 2).times \
                .and_return { |dir|
          dir =~ %r!#{@asset_root_dir}/(#{directories_regexp})$!
        }
      end

      def expected_html_for_asset_root_with(directories)
        mock_asset_root_with(directories)

        expected_html = @html.clone
        if not directories.empty?
          directories_regexp = directories.join('|')
          expected_html.gsub!(/"(\/(#{directories_regexp})\/)/,
                              '"%s\1' % @asset_root_dir)
        end

        return expected_html
      end

      def test_with_directories(directories)
        @temp_file.should_receive(:write) \
          .with expected_html_for_asset_root_with(directories)
        Capybara.save_page @html
      end

      context "asset_root contains some directories" do
        it "should rewrite relative paths to absolute local paths" do
          test_with_directories([ 'javascripts', 'images' ])
        end
      end

      context "asset_root path contains no directories" do
        it "should not rewrite any relative paths" do
          test_with_directories([ ])
        end
      end
    end
  end

  describe "#delete_saved_pages" do
    before do
      @path = File.join 'tmp', 'failed_scenarios'
      Capybara.should_receive(:save_and_open_page_path).and_return @path
    end

    it "should remove all html files in the save_and_open_page_path directory" do
      Dir.should_receive(:glob).with(File.join(@path, '*.html')).
        and_yield('one.html').
        and_yield('two.html')
      File.should_receive(:delete).with('one.html')
      File.should_receive(:delete).with('two.html')

      Capybara.delete_saved_pages
    end
  end
end
