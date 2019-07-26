# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'shared_selenium_node'
require 'rspec/shared_spec_matchers'

CHROME_DRIVER = :selenium_chrome

Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome-beta' if ENV['CI'] && ENV['CHROME_BETA']

browser_options = ::Selenium::WebDriver::Chrome::Options.new
browser_options.headless! if ENV['HEADLESS']
browser_options.add_option(:w3c, ENV['W3C'] != 'false')

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, timeout: 30).tap do |driver|
    driver.browser.download_path = Capybara.save_path
  end
end

Capybara.register_driver :selenium_chrome_not_clear_storage do |app|
  chrome_options = {
    browser: :chrome,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_local_storage: false, clear_session_storage: false))
end

Capybara.register_driver :selenium_chrome_not_clear_session_storage do |app|
  chrome_options = {
    browser: :chrome,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_session_storage: false))
end

Capybara.register_driver :selenium_chrome_not_clear_local_storage do |app|
  chrome_options = {
    browser: :chrome,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_local_storage: false))
end

Capybara.register_driver :selenium_driver_subclass_with_chrome do |app|
  subclass = Class.new(Capybara::Selenium::Driver)
  subclass.new(app, browser: :chrome, options: browser_options, timeout: 30)
end

module TestSessions
  Chrome = Capybara::Session.new(CHROME_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]

Capybara::SpecHelper.log_selenium_driver_version(Selenium::WebDriver::Chrome) if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#click_link can download a file$/
    skip 'Need to figure out testing of file downloading on windows platform' if Gem.win_platform?
  when /Capybara::Session selenium_chrome Capybara::Window#maximize/
    pending "Chrome headless doesn't support maximize" if ENV['HEADLESS']
  when /details non-summary descendants should be non-visible/
    pending 'Chromedriver built-in is_displayed is currently broken' if ENV['W3C'] == 'false'
  end
end

RSpec.describe 'Capybara::Session with chrome' do
  include Capybara::SpecHelper
  ['Capybara::Session', 'Capybara::Node', Capybara::RSpecMatchers].each do |examples|
    include_examples examples, TestSessions::Chrome, CHROME_DRIVER
  end

  context 'storage' do
    describe '#reset!' do
      it 'clears storage by default' do
        session = TestSessions::Chrome
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end

      it 'does not clear storage when false' do
        session = Capybara::Session.new(:selenium_chrome_not_clear_storage, TestApp)
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).not_to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).not_to be_empty
      end

      it 'can not clear session storage' do
        session = Capybara::Session.new(:selenium_chrome_not_clear_session_storage, TestApp)
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).not_to be_empty
      end

      it 'can not clear local storage' do
        session = Capybara::Session.new(:selenium_chrome_not_clear_local_storage, TestApp)
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).not_to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end
    end
  end

  context 'timeout' do
    it 'sets the http client read timeout' do
      expect(TestSessions::Chrome.driver.browser.send(:bridge).http.read_timeout).to eq 30
    end
  end

  describe 'filling in Chrome-specific date and time fields with keystrokes' do
    let(:datetime) { Time.new(1983, 6, 19, 6, 30) }
    let(:session) { TestSessions::Chrome }

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

  describe 'using subclass of selenium driver' do
    it 'works' do
      session = Capybara::Session.new(:selenium_driver_subclass_with_chrome, TestApp)
      session.visit('/form')
      expect(session).to have_current_path('/form')
    end
  end

  describe 'log access' do
    before { skip 'Only makes sense in W3C mode' if ENV['W3C'] == 'false' }

    it 'does not error getting log types' do
      skip if Gem::Version.new(session.driver.browser.capabilities['chrome']['chromedriverVersion'].split[0]) < Gem::Version.new('75.0.3770.90')
      expect do
        session.driver.browser.manage.logs.available_types
      end.not_to raise_error
    end

    it 'does not error when getting logs' do
      expect do
        session.driver.browser.manage.logs.get(:browser)
      end.not_to raise_error
    end
  end
end
