require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'capybara/save_and_open_page'
require 'launchy'
describe Capybara::SaveAndOpenPage do
  describe "#save_save_and_open_page" do
    before do

      @time = Time.new.strftime("%Y%m%d%H%M%S")
      name = "capybara-#{@time}.html"
      File.should_receive(:exist?).and_return true
      @temp_file = File.new(name,'w')
      @temp_file.stub!(:write)
      @temp_file.stub!(:close)

      File.should_receive(:new).and_return @temp_file

      @html = <<-HTML
        <html>
          <head>
          </head>
          <body>
            <h1>test</h1>
          </body>
        <html>
      HTML

      Launchy::Browser.stub(:run)
    end

    it "should create a new temporary file" do
      @temp_file.should_receive(:write).with @html
      Capybara::SaveAndOpenPage.save_and_open_page @html
    end

    it "should open the file in the browser" do
      path = "#{@temp_file.path}"
      Capybara::SaveAndOpenPage.should_receive(:open_in_browser).with(path)
      Capybara::SaveAndOpenPage.save_and_open_page @html
    end
  end
end
