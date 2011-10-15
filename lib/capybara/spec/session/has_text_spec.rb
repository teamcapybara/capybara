shared_examples_for 'has_text' do
  describe '#has_text?' do
    it 'works' do
      @session.visit('/with_html')
      @session.should have_text('Lorem')
    end
  end

  describe '#has_no_text?' do
    it 'works' do
      @session.visit('/with_html')
      @session.should have_no_text('Merol')
    end
  end
end
