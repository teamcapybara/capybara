# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'

RSpec.shared_examples 'Capybara::Node' do |session, _mode|
  let(:session) { session }

  context '#content_editable?' do
    it 'returns true when the element is content editable' do
      session.visit('/with_js')
      expect(session.find(:css, '#existing_content_editable').base.content_editable?).to be true
      expect(session.find(:css, '#existing_content_editable_child').base.content_editable?).to be true
    end

    it 'returns false when the element is not content editable' do
      session.visit('/with_js')
      expect(session.find(:css, '#drag').base.content_editable?).to be false
    end
  end

  context '#send_keys' do
    it 'should process space' do
      session.visit('/form')
      session.find(:css, '#address1_city').send_keys('ocean', [:shift, :space, 'side'])
      expect(session.find(:css, '#address1_city').value).to eq 'ocean SIDE'
    end
  end
end
