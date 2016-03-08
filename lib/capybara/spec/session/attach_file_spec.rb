# frozen_string_literal: true
Capybara::SpecHelper.spec "#attach_file" do
  before do
    @test_file_path = File.expand_path('../fixtures/test_file.txt', File.dirname(__FILE__))
    @another_test_file_path = File.expand_path('../fixtures/another_test_file.txt', File.dirname(__FILE__))
    @test_jpg_file_path = File.expand_path('../fixtures/capybara.jpg', File.dirname(__FILE__))
    @session.visit('/form')
  end

  context "with normal form" do
    it "should set a file path by id" do
      @session.attach_file "form_image", __FILE__
      @session.click_button('awesome')
      expect(extract_results(@session)['image']).to eq(File.basename(__FILE__))
    end

    it "should set a file path by label" do
      @session.attach_file "Image", __FILE__
      @session.click_button('awesome')
      expect(extract_results(@session)['image']).to eq(File.basename(__FILE__))
    end

    it "casts to string" do
      @session.attach_file :"form_image", __FILE__
      @session.click_button('awesome')
      expect(extract_results(@session)['image']).to eq(File.basename(__FILE__))
    end
  end

  context "with multipart form" do
    it "should set a file path by id" do
      @session.attach_file "form_document", @test_file_path
      @session.click_button('Upload Single')
      expect(@session).to have_content(File.read(@test_file_path))
    end

    it "should set a file path by label" do
      @session.attach_file "Single Document", @test_file_path
      @session.click_button('Upload Single')
      expect(@session).to have_content(File.read(@test_file_path))
    end

    it "should not break if no file is submitted" do
      @session.click_button('Upload Single')
      expect(@session).to have_content('No file uploaded')
    end

    it "should send content type text/plain when uploading a text file" do
      @session.attach_file "Single Document", @test_file_path
      @session.click_button 'Upload Single'
      expect(@session).to have_content('text/plain')
    end

    it "should send content type image/jpeg when uploading an image" do
      @session.attach_file "Single Document", @test_jpg_file_path
      @session.click_button 'Upload Single'
      expect(@session).to have_content('image/jpeg')
    end

    it "should not break when using HTML5 multiple file input" do
      @session.attach_file "Multiple Documents", @test_file_path
      @session.click_button('Upload Multiple')
      expect(@session).to have_content(File.read(@test_file_path))
      expect(@session.body).to include("1 | ")#number of files
    end

    it  "should not break when using HTML5 multiple file input uploading multiple files" do
      pending "Selenium is buggy on this, see http://code.google.com/p/selenium/issues/detail?id=2239" if @session.respond_to?(:mode) && @session.mode.to_s =~ /^selenium/
      @session.attach_file "Multiple Documents", [@test_file_path, @another_test_file_path]
      @session.click_button('Upload Multiple')
      expect(@session.body).to include("2 | ")#number of files
      expect(@session.body).to include(File.read(@test_file_path))
      expect(@session.body).to include(File.read(@another_test_file_path))
    end

    it "should not send anything when attaching no files to a multiple upload field" do
      @session.click_button('Upload Empty Multiple')
      expect(@session).to have_content("Successfully ignored empty file field")
    end
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find file field \"does not exist\""
      expect do
        @session.attach_file('does not exist', @test_file_path)
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a path that doesn't exist" do
    it "should raise an error" do
      expect { @session.attach_file('Image', '/no_such_file.png') }.to raise_error(Capybara::FileNotFound)
    end
  end

  context "with :exact option" do
    it "should set a file path by partial label when false" do
      @session.attach_file "Imag", __FILE__, :exact => false
      @session.click_button('awesome')
      expect(extract_results(@session)['image']).to eq(File.basename(__FILE__))
    end

    it "not allow partial matches when true" do
      expect do
        @session.attach_file "Imag", __FILE__, :exact => true
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
