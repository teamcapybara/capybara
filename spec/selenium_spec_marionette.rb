# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

browser_options = ::Selenium::WebDriver::Firefox::Options.new
browser_options.args << '--headless' if ENV['HEADLESS']
browser_options.add_preference 'dom.file.createInChild', true
# browser_options.add_option("log", {"level": "trace"})

browser_options.profile = Selenium::WebDriver::Firefox::Profile.new.tap do |profile|
  profile['browser.download.dir'] = Capybara.save_path
  profile['browser.download.folderList'] = 2
  profile['browser.helperApps.neverAsk.saveToDisk'] = 'text/csv'
end

Capybara.register_driver :selenium_marionette do |app|
  # ::Selenium::WebDriver.logger.level = "debug"
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: { marionette: true, 'moz:webdriverClick': true },
    options: browser_options,
    # Get a trace level log from geckodriver
    # :driver_opts => { args: ['-vv'] }
  )
end

Capybara.register_driver :selenium_marionette_clear_storage do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: { marionette: true },
    clear_local_storage: true,
    clear_session_storage: true,
    options: browser_options
  )
end

module TestSessions
  SeleniumMarionette = Capybara::Session.new(:selenium_marionette, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]
skipped_tests << :windows if ENV['TRAVIS'] && ENV['SKIP_WINDOW']

$stdout.puts `#{Selenium::WebDriver::Firefox.driver_path} --version` if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::SeleniumMarionette, 'selenium', capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when 'Capybara::Session selenium node #send_keys should generate key events',
       'Capybara::Session selenium node #send_keys should allow for multiple simultaneous keys',
       'Capybara::Session selenium node #send_keys should send special characters'
    pending "selenium-webdriver/geckodriver doesn't support complex sets of characters"
  when 'Capybara::Session selenium node #click should allow multiple modifiers'
    pending "Firefox doesn't generate an event for shift+control+click" if marionette_gte?(62, @session)
  when /^Capybara::Session selenium node #double_click/
    pending "selenium-webdriver/geckodriver doesn't generate double click event" if marionette_lt?(59, @session)
  when 'Capybara::Session selenium #refresh it reposts'
    skip 'Firefox insists on prompting without providing a way to suppress'
  when 'Capybara::Session selenium #accept_prompt should accept the prompt with a blank response when there is a default'
    pending "Geckodriver doesn't set a blank response currently"
  end
end

RSpec.describe 'Capybara::Session with firefox' do # rubocop:disable RSpec/MultipleDescribes
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::SeleniumMarionette, :selenium_marionette
  include_examples  Capybara::RSpecMatchers, TestSessions::SeleniumMarionette, :selenium_marionette
end

RSpec.describe Capybara::Selenium::Driver do
  before do
    @driver = Capybara::Selenium::Driver.new(TestApp, browser: :firefox, options: browser_options)
  end

  describe '#quit' do
    it 'should reset browser when quit' do
      expect(@driver.browser).to be_truthy
      @driver.quit
      # access instance variable directly so we don't create a new browser instance
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end

    context 'with errors' do
      before do
        @original_browser = @driver.browser
      end

      after do
        # Ensure browser is actually quit so we don't leave hanging processe
        RSpec::Mocks.space.proxy_for(@original_browser).reset
        @original_browser.quit
      end

      it 'warns UnknownError returned during quit because the browser is probably already gone' do
        allow(@driver).to receive(:warn)
        allow(@driver.browser).to(
          receive(:quit)
          .and_raise(Selenium::WebDriver::Error::UnknownError, 'random message')
        )

        expect { @driver.quit }.not_to raise_error
        expect(@driver.instance_variable_get(:@browser)).to be_nil
        expect(@driver).to have_received(:warn).with(/random message/)
      end

      it 'ignores silenced UnknownError returned during quit because the browser is almost definitely already gone' do
        allow(@driver).to receive(:warn)
        allow(@driver.browser).to(
          receive(:quit)
          .and_raise(Selenium::WebDriver::Error::UnknownError, 'Error communicating with the remote browser')
        )

        expect { @driver.quit }.not_to raise_error
        expect(@driver.instance_variable_get(:@browser)).to be_nil
        expect(@driver).not_to have_received(:warn)
      end
    end
  end

  context 'storage' do
    describe '#reset!' do
      it 'does not clear either storage by default' do
        @session = TestSessions::SeleniumMarionette
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        expect(@session.driver.browser.local_storage.keys).not_to be_empty
        expect(@session.driver.browser.session_storage.keys).not_to be_empty
      end

      it 'clears storage when set' do
        @session = Capybara::Session.new(:selenium_marionette_clear_storage, TestApp)
        @session.visit('/with_js')
        @session.find(:css, '#set-storage').click
        @session.reset!
        @session.visit('/with_js')
        expect(@session.driver.browser.local_storage.keys).to be_empty
        expect(@session.driver.browser.session_storage.keys).to be_empty
      end
    end
  end

  context '#refresh' do
    def extract_results(session)
      expect(session).to have_xpath("//pre[@id='results']")
      YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.inner_html.lstrip
    end

    it 'can repost by accepting confirm' do
      @session = TestSessions::SeleniumMarionette
      @session.visit('/form')
      @session.select('Sweden', from: 'form_region')
      @session.click_button('awesome')
      sleep 1
      expect do
        @session.accept_confirm(wait: 0.1) do
          @session.refresh
          sleep 2
        end
        sleep 1
      end.to change { extract_results(@session)['post_count'] }.by(1)
    end
  end
end

RSpec.describe Capybara::Selenium::Node do
  context '#click' do
    it 'warns when attempting on a table row' do
      session = TestSessions::SeleniumMarionette
      session.visit('/tables')
      tr = session.find(:css, '#agent_table tr:first-child')
      allow(tr.base).to receive(:warn)
      tr.click
      expect(tr.base).to have_received(:warn).with(/Clicking the first cell in the row instead/)
    end

    it 'should allow multiple modifiers', requires: [:js] do
      session = TestSessions::SeleniumMarionette
      session.visit('with_js')
      # Firefox v62+ doesn't generate an event for control+shift+click
      session.find(:css, '#click-test').click(:alt, :ctrl, :meta)
      # it also triggers a contextmenu event when control is held so don't check click type
      expect(session).to have_link('Has been alt control meta')
    end
  end
end
