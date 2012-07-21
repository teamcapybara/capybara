Capybara::SpecHelper.spec '#text' do
  it "should print the text of the page" do
    @session.visit('/with_simple_html')
    @session.text.should == 'Bar'
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }
    it "should print the text of the page" do
      @session.visit('/with_simple_html')
      @session.text.should == 'Bar'
    end
    after { Capybara.default_selector = :xpath }
  end

  it "should strip whitespace" do
    @session.visit('/with_html')
    n = @session.find(:css, '#second')
    @session.find(:css, '#second').text.should =~ \
      /\ADuis aute .* text with whitespace .* est laborum\.\z/
  end
end
