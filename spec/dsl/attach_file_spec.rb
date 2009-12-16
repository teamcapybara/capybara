module AttachFileSpec
  shared_examples_for "attach_file" do

    describe "#attach_file" do
      before do
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
        before do
          @test_file_path = File.expand_path('../fixtures/test_file.txt', File.dirname(__FILE__))
        end

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
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running { @session.attach_file('does not exist', 'foo.txt') }.should raise_error(Capybara::ElementNotFound)
        end
      end
    end
  end
end  