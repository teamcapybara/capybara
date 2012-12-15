#coding: US-ASCII
Capybara::SpecHelper.spec "#save_screenshot" do
  let(:image_path) { File.join(Dir.tmpdir, 'capybara-screenshot.png') }

  before do
    @session.visit '/'
    @session.save_screenshot image_path
  end

  it "should generate PNG file", :requires => [:screenshot] do
    magic = File.read(image_path, 4)
    magic.should eq "\x89PNG"
  end
end
