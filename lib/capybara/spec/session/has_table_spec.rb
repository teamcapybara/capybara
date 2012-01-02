shared_examples_for "has_table" do
  describe '#has_table?' do
    before do
      @session.visit('/tables')
    end

    it "should be true if the table is on the page" do
      @session.should have_table('Villain')
      @session.should have_table('villain_table')
    end

    it "should be false if the table is not on the page" do
      @session.should_not have_table('Monkey')
    end
  end

  describe '#has_no_table?' do
    before do
      @session.visit('/tables')
    end

    it "should be false if the table is on the page" do
      @session.should_not have_no_table('Villain')
      @session.should_not have_no_table('villain_table')
    end

    it "should be true if the table is not on the page" do
      @session.should have_no_table('Monkey')
    end
  end
end



