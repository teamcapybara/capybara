shared_examples_for "attach_file" do

  describe "#attach_file" do
    before do
      @test_file_path = File.expand_path('../fixtures/test_file.txt', File.dirname(__FILE__))
      @test_jpg_file_path = File.expand_path('../fixtures/capybara.jpg', File.dirname(__FILE__))
      @session.visit('/form')
    end

    context "with normal form" do
      it "should set a file path by id" do
        @session.attach_file "form_image", __FILE__
        @session.click_button('awesome')
        extract_results(@session)['image'].should == File.basename(__FILE__)
      end

      it "should set a file path by label" do
        @session.attach_file "Image", __FILE__
        @session.click_button('awesome')
        extract_results(@session)['image'].should == File.basename(__FILE__)
      end
    end

    context "with multipart form" do
      it "should set a file path by id" do
        @session.attach_file "form_document", @test_file_path
        @session.click_button('Upload')
        @session.body.should include(File.read(@test_file_path))
      end

      it "should set a file path by label" do
        @session.attach_file "Document", @test_file_path
        @session.click_button('Upload')
        @session.body.should include(File.read(@test_file_path))
      end

      it "should not break if no file is submitted" do
        @session.click_button('Upload')
        @session.body.should include('No file uploaded')
      end

      it "should send content type text/plain when uploading a text file" do
        @session.attach_file "Document", @test_file_path
        @session.click_button 'Upload'
        @session.body.should include('text/plain')
      end

      it "should send content type image/jpeg when uploading an image" do
        @session.attach_file "Document", @test_jpg_file_path
        @session.click_button 'Upload'
        @session.body.should include('image/jpeg')
      end

      it  "should not break when using HTML5 multiple file input" do
        @session.attach_file "Multiple Documents", @test_file_path
        @session.click_button('Upload Multiple')
        @session.body.should include(File.read(@test_file_path))
      end

      context "when providing file content" do

        it "should supply a tempfile path with the provided content" do
          content = "double super awesome"
          @session.attach_file("Document", :contents => content)
          @session.click_button('Upload')
          @session.body.should include(content)
        end

        it "should send content type text/plain when specifying a plaintext extension" do
          @session.attach_file('Document', :extension => '.txt', :contents => 'a text file')
          @session.click_button 'Upload'
          @session.body.should include('text/plain')
        end

        it "should send content type image/jpeg when specifying an image extension" do
          @session.attach_file('Document', :extension => '.jpg', :contents => 'not actually a jpg')
          @session.click_button 'Upload'
          @session.body.should include('image/jpeg')
        end

      end

    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.attach_file('does not exist', @test_file_path) }.should raise_error(Capybara::ElementNotFound)
      end
    end

    context "with a path that doesn't exist" do
      it "should raise an error" do
        running { @session.attach_file('Image', '/no_such_file.png') }.should raise_error(Capybara::FileNotFound)
      end
    end
  end
end
