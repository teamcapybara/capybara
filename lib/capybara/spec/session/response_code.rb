shared_examples_for "session with response code support" do
  describe '#response_code' do
    it "should return response codes" do
      @session.visit('/with_simple_html')     
      @session.response_code.should == 200
    end
  end
end

shared_examples_for "session without response code support" do
  describe "#response_code" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.response_code
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
