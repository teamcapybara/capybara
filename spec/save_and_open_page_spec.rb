require 'spec_helper'

require 'capybara/util/save_and_open_page'
require 'launchy'
describe Capybara do
  describe ".save_page & .save_and_open_page" do
    before do
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

      Launchy.stub(:open)
    end

    def default_file_expectations
      @temp_file.stub!(:path).and_return('page.html')

      File.should_receive(:exist?).and_return true
      File.should_receive(:new).and_return @temp_file
    end

    describe "defaults" do
      before do
        default_file_expectations
      end

      it "should create a new temporary file" do
        @temp_file.should_receive(:write).with @html
        Capybara.save_page @html, 'page.html'
      end

      it "should open the file in the browser" do
        Capybara.should_receive(:open_in_browser).with('page.html')
        Capybara.save_and_open_page @html, 'page.html'
      end
    end

    describe "custom output path" do
      before do
        @custom_path = File.join('tmp', 'capybara')
        @custom_name = File.join(@custom_path, 'page.html')

        @temp_file.stub!(:path).and_return(@custom_name)

        Capybara.should_receive(:save_and_open_page_path).at_least(:once).and_return(@custom_path)
      end

      it "should create a new temporary file in the custom path" do
        File.should_receive(:directory?).and_return true
        File.should_receive(:exist?).and_return true
        File.should_receive(:new).and_return @temp_file

        @temp_file.should_receive(:write).with @html
        Capybara.save_page @html, 'page.html'
      end

      it "should open the file - in the custom path - in the browser" do
        Capybara.should_receive(:open_in_browser).with(@custom_name)
        Capybara.save_and_open_page @html, 'page.html'
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
        Capybara.save_page @html, 'page.html'
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
end
