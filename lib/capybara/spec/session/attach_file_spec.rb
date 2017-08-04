# frozen_string_literal: true
Capybara::SpecHelper.spec "#attach_file" do
  before do
    @test_file_path = File.expand_path('../fixtures/test_file.txt', File.dirname(__FILE__))
    @another_test_file_path = File.expand_path('../fixtures/another_test_file.txt', File.dirname(__FILE__))
    @test_jpg_file_path = File.expand_path('../fixtures/capybara.jpg', File.dirname(__FILE__))
    @no_extension_file_path = File.expand_path('../fixtures/no_extension', File.dirname(__FILE__))
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

    it "should not break when uploading a file without extension" do
      @session.attach_file "Single Document", @no_extension_file_path
      @session.click_button 'Upload Single'
      expect(@session).to have_content(File.read(@no_extension_file_path))
    end

    it "should not break when using HTML5 multiple file input" do
      @session.attach_file "Multiple Documents", @test_file_path
      @session.click_button('Upload Multiple')
      expect(@session).to have_content(File.read(@test_file_path))
      expect(@session.body).to include("1 | ")#number of files
    end

    it  "should not break when using HTML5 multiple file input uploading multiple files" do
      pending "Selenium is buggy on this, see http://code.google.com/p/selenium/issues/detail?id=2239" if @session.respond_to?(:mode) && @session.mode.to_s =~ /^selenium_(firefox|marionette)/
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
      msg = "Unable to find visible file field \"does not exist\" that is not disabled"
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
      @session.attach_file "Imag", __FILE__, exact:  false
      @session.click_button('awesome')
      expect(extract_results(@session)['image']).to eq(File.basename(__FILE__))
    end

    it "not allow partial matches when true" do
      expect do
        @session.attach_file "Imag", __FILE__, exact:  true
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :make_visible option", requires: [:js, :es_args] do
    it "applies a default style change when true" do
      @session.visit('/with_js')
      expect { @session.attach_file("hidden_file", __FILE__) }.to raise_error Capybara::ElementNotFound
      expect {
        @session.attach_file("hidden_file", __FILE__, make_visible: true)
      }.not_to raise_error
    end

    it "accepts a hash of styles to be applied" do
      @session.visit('/with_js')
      expect {
        @session.attach_file("hidden_file", __FILE__, make_visible: { opacity: 1, display: 'block' })
      }.not_to raise_error
    end

    it "raises an error when the file input is not made visible" do
      @session.visit('/with_js')
      expect {
        @session.attach_file("hidden_file", __FILE__, make_visible: { color: 'red' })
      }.to raise_error(Capybara::ExpectationNotMet)
    end

    it "resets the style when done" do
      @session.visit('/with_js')
      @session.attach_file("hidden_file", __FILE__, make_visible: true)
      expect(@session.evaluate_script("arguments[0].style.display", @session.find(:css, '#hidden_file', visible: :all))).to eq 'none'
    end
  end
end
