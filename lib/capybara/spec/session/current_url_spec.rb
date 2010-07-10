shared_examples_for "current_url" do  
  describe '#current_url' do
    it "should return the current url" do
      @session.visit('/form')
      @session.current_url.should =~ %r(http://[^/]+/form)
    end
  end

  describe '#current_path' do
    it 'should show the correct location' do
      @session.visit('/foo')
      @session.current_path.should == '/foo'
    end
  end
end
