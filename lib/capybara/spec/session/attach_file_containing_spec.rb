
shared_examples_for "attach_file_containing" do

  describe "#attach_file_containing" do

    before do
      @session.visit('/form')
    end

    it "should supply a tempfile path with the provided content" do
      content = "double super awesome"
      @session.attach_file_containing("Document", content)
      @session.click_button('Upload')
      @session.body.should include(content)
    end

    context "when specifying a file extension" do

      it "should send content type text/plain when specifying a plaintext extension" do
        @session.attach_file_containing('Document', '.txt', 'a text file')
        @session.click_button 'Upload'
        @session.body.should include('text/plain')
      end

      it "should send content type image/jpeg when specifying an image extension" do
        @session.attach_file_containing('Document', '.jpg', 'not actually a jpg')
        @session.click_button 'Upload'
        @session.body.should include('image/jpeg')
      end

    end

    pending "when supplying extra arguments" do
      it "should pass extra arguments to Tempfile" do
        # TODO: I'm entirely unsure on how to test this
      end
    end

  end

end
