Capybara::SpecHelper.spec '#body' do
  it "should return the unmodified page body" do
    @session.visit('/')
    @session.should have_content('Hello world!') # wait for content to appear if visit is async
    @session.body.should include('Hello world!')
  end

  if "".respond_to?(:encoding)
    context "encoding of response between ascii and utf8" do
      it "should be valid with html entities" do
        @session.visit('/with_html_entities')
        lambda { @session.body.encode!("UTF-8") }.should_not raise_error
      end

      it "should be valid without html entities" do
        @session.visit('/with_html')
        lambda { @session.body.encode!("UTF-8") }.should_not raise_error
      end
    end
  end
end
