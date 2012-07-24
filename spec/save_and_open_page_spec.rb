require 'spec_helper'

require 'capybara/util/save_and_open_page'

describe Capybara do
  describe "#save_page" do
    let(:alternative_path) { File.join(Dir.pwd, "save_and_open_page_tmp") }
    after do
      Capybara.save_and_open_page_path = nil
      Dir.glob("capybara-*.html").each do |file|
        FileUtils.rm(file)
      end
      FileUtils.rm_rf alternative_path
    end

    it "saves the page in the root directory" do
      html = "<h1>Hello world</h1>"
      Capybara.save_page(html)
      path = Dir.glob("capybara-*.html").first
      File.read(path).should == html
    end

    it "generates a sensible filename" do
      html = "<h1>Hello world</h1>"
      Capybara.save_page(html)
      path = Dir.glob("capybara-*.html").first
      filename = path.split("/").last
      filename.should =~ /^capybara-\d+\.html$/
    end

    it "can store files in a specified directory" do
      Capybara.save_and_open_page_path = alternative_path
      html = "<h1>Hello world</h1>"
      Capybara.save_page(html)
      path = Dir.glob(alternative_path + "/capybara-*.html").first
      File.read(path).should == html
    end

    it "uses the given filename" do
      html = "<h1>Hello world</h1>"
      Capybara.save_page(html, "capybara-001122.html")
      File.read("capybara-001122.html").should == html
    end

    it "returns the filename" do
      html = "<h1>Hello world</h1>"
      result = Capybara.save_page(html)
      path = Dir.glob("capybara-*.html").first
      filename = path.split("/").last
      result.should == filename
    end
  end
end
