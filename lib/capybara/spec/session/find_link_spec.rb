Capybara::SpecHelper.spec '#find_link' do
  before do
    @session.visit('/with_html')
  end

  it "should find any field" do
    expect(@session.find_link('foo').text).to eq("ullamco")
    expect(@session.find_link('labore')[:href]).to match %r(/with_simple_html$)
  end

  it "casts to string" do
    expect(@session.find_link(:'foo').text).to eq("ullamco")
  end

  it "should raise error if the field doesn't exist" do
    expect do
      @session.find_link('Does not exist')
    end.to raise_error(Capybara::ElementNotFound)
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      expect(@session.find_link('abo', :exact => false).text).to eq("labore")
    end

    it "should not accept partial matches when true" do
      expect do
        @session.find_link('abo', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end
end
