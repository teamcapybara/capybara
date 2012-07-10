shared_examples_for "session with screenshot support" do
  describe "#save_screenshot" do
    let(:image_path) { File.join(Dir.tmpdir, 'capybara-screenshot.png') }

    before do
      @session.visit '/'
      @session.save_screenshot image_path
    end

    it "should generate PNG file" do
      magic = File.read(image_path, 4)
      magic.should eq "\x89PNG"
    end
  end
end

shared_examples_for "session without screenshot support" do
  describe "#save_screenshot" do
    before do
      @session.visit('/')
    end

    it "should raise an error" do
      running {
        @session.save_screenshot 'raise_error.png'
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
