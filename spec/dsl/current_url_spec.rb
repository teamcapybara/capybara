shared_examples_for "current_url" do  
  describe '#current_url' do
    it "should return the current url" do
      @session.visit('/form')
      @session.current_url.should =~ %r((file|http)://[^/]*/form)
    end
  end
end
