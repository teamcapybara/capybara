# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

EDGE_DRIVER = :selenium_edge

browser_options = ::Selenium::WebDriver::Edge::Options.new

Capybara.register_driver :selenium_edge do |app|
  Capybara::Selenium::Driver.new(app, browser: :edge, options: browser_options, timeout: 30).tap do |driver|
    # driver.browser.download_path = Capybara.save_path
  end
end

Capybara.register_driver :selenium_edge_not_clear_storage do |app|
  edge_options = {
    browser: :edge,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, edge_options.merge(clear_local_storage: false, clear_session_storage: false))
end

module TestSessions
  Edge = Capybara::Session.new(EDGE_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]

Capybara::SpecHelper.log_selenium_driver_version(Selenium::WebDriver::Edge) if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::Edge, EDGE_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#click_link can download a file$/
    skip 'Need to figure out testing of file downloading on windows platform' if Gem.win_platform?
  when /Capybara::Session selenium_edge Capybara::Window#maximize/
    pending "Edge headless doesn't support maximize" if ENV['HEADLESS']
  end
end

RSpec.describe 'Capybara::Session with edge' do
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::Edge, EDGE_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Edge, EDGE_DRIVER

  context 'storage' do
    describe '#reset!' do
      it 'clears storage by default' do
        session = TestSessions::Edge
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end

      it 'does not clear storage when false' do
        session = Capybara::Session.new(:selenium_edge_not_clear_storage, TestApp)
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).not_to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).not_to be_empty
      end
    end
  end

  context 'timeout' do
    it 'sets the http client read timeout' do
      expect(TestSessions::Edge.driver.browser.send(:bridge).http.read_timeout).to eq 30
    end
  end

  describe 'filling in Edge-specific date and time fields with keystrokes' do
    let(:datetime) { Time.new(1983, 6, 19, 6, 30) }
    let(:session) { TestSessions::Edge }

    before do
      session.visit('/form')
    end

    it 'should fill in a date input with a String' do
      session.fill_in('form_date', with: '06/19/1983')
      session.click_button('awesome')
      expect(Date.parse(extract_results(session)['date'])).to eq datetime.to_date
    end

    it 'should fill in a time input with a String' do
      session.fill_in('form_time', with: '06:30A')
      session.click_button('awesome')
      results = extract_results(session)['time']
      expect(Time.parse(results).strftime('%r')).to eq datetime.strftime('%r')
    end

    it 'should fill in a datetime input with a String' do
      session.fill_in('form_datetime', with: "06/19/1983\t06:30A")
      session.click_button('awesome')
      expect(Time.parse(extract_results(session)['datetime'])).to eq datetime
    end
  end
end
