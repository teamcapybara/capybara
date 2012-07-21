Capybara::SpecHelper.spec '#response_headers' do
  it "should return response headers", :requires => [:response_headers] do
    @session.visit('/with_simple_html')
    @session.response_headers['Content-Type'].should =~ %r(text/html)
  end
end
