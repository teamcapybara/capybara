require File.expand_path('spec_helper', File.dirname(__FILE__))


shared_examples_for "session with headers support" do
  
  describe '#response_headers' do
    it "should return response headers" do
      @session.visit('/with_simple_html')     
      @session.response_headers['Content-Type'].should == 'text/html'
    end
  end
  
end
