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

  context '#visible?' do
    let(:bridge) do
      session.driver.browser.send(:bridge)
    end

    around do |example|
      native_displayed = session.driver.options[:native_displayed]
      example.run
      session.driver.options[:native_displayed] = native_displayed
    end

    before do
      allow(bridge).to receive(:execute_atom).and_call_original
    end

    it 'will use native displayed if told to' do
      pending "Chromedriver < 76.0.3809.25 doesn't support native displayed in W3C mode" if chrome_lt?(76, session) && (ENV['W3C'] != 'false')

      session.driver.options[:native_displayed] = true
      session.visit('/form')
      session.find(:css, '#address1_city', visible: true)

      expect(bridge).not_to have_received(:execute_atom)
    end

    it "won't use native displayed if told not to" do
      skip 'Non-W3C uses native' if chrome?(session) && (ENV['W3C'] == 'false')

      session.driver.options[:native_displayed] = false
      session.visit('/form')
      session.find(:css, '#address1_city', visible: true)

      expect(bridge).to have_received(:execute_atom).with(:isDisplayed, any_args)
    end
  end
end
