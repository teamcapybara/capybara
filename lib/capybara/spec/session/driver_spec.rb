# frozen_string_literal: true

Capybara::SpecHelper.spec 'Driver' do
  context 'freeze_page', requires: %i[freeze js] do
    it 'can pause a page' do
      @session.visit('/with_js')
      @session.find(:css, '#clickable').click
      sleep 0.1
      @session.driver.freeze_page

      expect(@session).to have_css('#clickable-processing')
      sleep 3 # Time needs to be longer than click action delay
      expect(@session).not_to have_css('#has-been-clicked')
      expect(@session).to have_css('#clickable-processing')

      @session.driver.thaw_page
      expect(@session).to have_css('#has-been-clicked').and(have_no_css('#clickable-processing'))
    end

    it "doesn't prevent driver JS" do
      @session.visit('/with_js')
      @session.find(:css, '#clickable')
      @session.driver.freeze_page

      expect(@session.evaluate_script('1==1')).to eq true

      @session.driver.thaw_page
    end
  end
end
