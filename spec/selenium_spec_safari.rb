# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

SAFARI_DRIVER = :selenium_safari

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Safari::Service
else
  ::Selenium::WebDriver::Safari
end.driver_path = '/Applications/Safari Technology Preview.app/Contents/MacOS/safaridriver'

browser_options = ::Selenium::WebDriver::Safari::Options.new
# browser_options.headless! if ENV['HEADLESS']
# browser_options.add_option(:w3c, !!ENV['W3C'])

Capybara.register_driver :selenium_safari do |app|
  Capybara::Selenium::Driver.new(app, browser: :safari, options: browser_options, timeout: 30).tap do |driver|
    # driver.browser.download_path = Capybara.save_path
  end
end

Capybara.register_driver :selenium_safari_not_clear_storage do |app|
  safari_options = {
    browser: :safari,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, safari_options.merge(clear_local_storage: false, clear_session_storage: false))
end

module TestSessions
  Safari = Capybara::Session.new(SAFARI_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger windows drag]

Capybara::SpecHelper.log_selenium_driver_version(Selenium::WebDriver::Safari) if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::Safari, SAFARI_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /click_link can download a file/
    skip "safaridriver doesn't provide a way to set the download directory"
  when /Capybara::Session selenium_safari Capybara::Window#maximize/
    pending "Safari headless doesn't support maximize" if ENV['HEADLESS']
  when /Capybara::Session selenium_safari #visit without a server/,
       /Capybara::Session selenium_safari #visit with Capybara.app_host set should override server/,
       /Capybara::Session selenium_safari #reset_session! When reuse_server == false raises any standard errors caught inside the server during a second session/
    skip "Safari webdriver doesn't support multiple sessions"
  when /Capybara::Session selenium_safari #click_link with alternative text given to a contained image/,
       'Capybara::Session selenium_safari #click_link_or_button with enable_aria_label should click on link'
    pending 'safaridriver thinks these links are non-interactable for some unknown reason'
  when /Capybara::Session selenium_safari #attach_file with a block can upload by clicking the file input/
    skip "safaridriver doesn't allow clicking on file inputs"
  when /Capybara::Session selenium_safari #attach_file with a block can upload by clicking the label/
    skip 'hangs tests'
  when /Capybara::Session selenium_safari #check when checkbox hidden with Capybara.automatic_label_click == false with allow_label_click == true should check via the label if input is visible but blocked by another element/,
      'Capybara::Session selenium_safari node #click should not retry clicking when wait is disabled',
      'Capybara::Session selenium_safari node #click should allow to retry longer',
      'Capybara::Session selenium_safari node #click should retry clicking'
    pending "safaridriver doesn't return a specific enough error to deal with this"
  when /Capybara::Session selenium_safari #within_frame works if the frame is closed/,
       /Capybara::Session selenium_safari #switch_to_frame works if the frame is closed/
    skip 'Safari has a race condition when clicking an element that causes the frame to close. It will sometimes raise a NoSuchFrameError'
  when /Capybara::Session selenium_safari #reset_session! removes ALL cookies/
    skip 'Safari webdriver can only remove cookies for the current domain'
  when /Capybara::Session selenium_safari #refresh it reposts/
    skip "Safari opens an alert that can't be closed"
  when 'Capybara::Session selenium_safari node #double_click should allow to adjust the offset',
       'Capybara::Session selenium_safari node #double_click should double click an element'
    pending "safardriver doesn't generate a double click event"
  when 'Capybara::Session selenium_safari node #click should allow multiple modifiers',
       /Capybara::Session selenium_safari node #(click|right_click|double_click) should allow modifiers/
    pending "safaridriver doesn't take key state into account when clicking"
  when 'Capybara::Session selenium_safari #fill_in on a pre-populated textfield with a reformatting onchange should trigger change when clearing field'
    pending "safardriver clear doesn't generate change event"
  when 'Capybara::Session selenium_safari #go_back should fetch a response from the driver from the previous page',
       'Capybara::Session selenium_safari #go_forward should fetch a response from the driver from the previous page'
    skip 'safaridriver loses the ability to find elements in the document after `go_back`'
  when 'Capybara::Session selenium_safari node #send_keys should hold modifiers at top level'
    skip 'Need to look into this'
  end
end

RSpec.describe 'Capybara::Session with safari' do
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::Safari, SAFARI_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Safari, SAFARI_DRIVER

  context 'storage' do
    describe '#reset!' do
      it 'clears storage by default' do
        session = TestSessions::Safari
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end

      it 'does not clear storage when false' do
        skip "Safari webdriver doesn't support multiple sessions"
        session = Capybara::Session.new(:selenium_safari_not_clear_storage, TestApp)
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
      expect(TestSessions::Safari.driver.browser.send(:bridge).http.read_timeout).to eq 30
    end
  end

  describe 'filling in Safari-specific date and time fields with keystrokes' do
    let(:datetime) { Time.new(1983, 6, 19, 6, 30) }
    let(:session) { TestSessions::Safari }

    before do
      skip 'Too many other things broken currently'
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
