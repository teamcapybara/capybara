require 'spec_helper'
require "selenium-webdriver"

Capybara.register_driver :selenium_focus do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["focusmanager.testmode"] = true
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end

module TestSessions
  Selenium = Capybara::Session.new(:selenium_focus, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Selenium, "selenium", :capybara_skip => [
  :response_headers,
  :status_code,
  :trigger
]

RSpec.describe Capybara::Session do
  context 'with selenium driver' do
    before do
      @session = TestSessions::Selenium
    end

    describe '#driver' do
      it "should be a selenium driver" do
        expect(@session.driver).to be_an_instance_of(Capybara::Selenium::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        expect(@session.mode).to eq(:selenium_focus)
      end
    end

    describe "#reset!" do
      it "freshly reset session should not be touched" do
        @session.instance_variable_set(:@touched, true)
        @session.reset!
        expect(@session.instance_variable_get(:@touched)).to eq false
      end
    end

    describe "exit codes" do
      before do
        @current_dir = Dir.getwd
        Dir.chdir(File.join(File.dirname(__FILE__), '..'))
      end

      after do
        Dir.chdir(@current_dir)
      end

      it "should have return code 1 when running selenium_driver_rspec_failure.rb" do
        `rspec spec/fixtures/selenium_driver_rspec_failure.rb`
        expect($?.exitstatus).to be 1
      end

      it "should have return code 0 when running selenium_driver_rspec_success.rb" do
        `rspec spec/fixtures/selenium_driver_rspec_success.rb`
        expect($?.exitstatus).to be 0
      end
    end

    describe "#accept_alert" do
      it "supports a blockless mode" do
        @session.visit('/with_js')
        @session.click_link('Open alert')
        @session.accept_alert
        expect{@session.driver.browser.switch_to.alert}.to raise_error("No alert is present")
      end
    end

    context "#fill_in with { :clear => :backspace } fill_option", :requires => [:js] do
      it 'should fill in a field, replacing an existing value' do
        @session.visit('/form')
        @session.fill_in('form_first_name', :with => 'Harry',
                          fill_options: { clear: :backspace} )
        expect(@session.find(:fillable_field, 'form_first_name').value).to eq('Harry')
      end

      it 'should only trigger onchange once' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', :with => 'some value',
                         :fill_options => { :clear => :backspace })
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session.find(:css, '.change_event_triggered', :match => :one)).to have_text 'some value'
      end

      it 'should trigger change when clearing field' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', :with => '',
                         :fill_options => { :clear => :backspace })
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session).to have_selector(:css, '.change_event_triggered', :match => :one)
      end
    end

    context "#fill_in with { clear: :none } fill_options" do
      it 'should append to content in a field' do
        @session.visit('/form')
        @session.fill_in('form_first_name', :with => 'Harry',
                          fill_options: { clear: :none} )
        expect(@session.find(:fillable_field, 'form_first_name').value).to eq('JohnHarry')
      end
    end

    context "#fill_in with { clear: Array } fill_options" do
      it 'should pass the array through to the element', tw: true do
        #this is mainly for use with [[:ctrl, 'a'], :backspace] - however since that is platform dependant I'm testing with something less useful
        @session.visit('/form')
        @session.fill_in('form_first_name', :with => 'Harry',
                          fill_options: { clear: [[:shift, 'abc'], :backspace] } )
        expect(@session.find(:fillable_field, 'form_first_name').value).to eq('JohnABHarry')
      end
    end

    describe "#path" do
      it "returns xpath" do
        # this is here because it is testing for an XPath that is specific to the algorithm used in the selenium driver
        @session.visit('/path')
        element = @session.find(:link, 'Second Link')
        expect(element.path).to eq('/html/body/div[2]/a[1]')
      end
    end
  end
end

RSpec.describe Capybara::Selenium::Driver do
  before do
    @driver = Capybara::Selenium::Driver.new(TestApp, browser: :firefox)
  end

  describe '#quit' do
    it "should reset browser when quit" do
      expect(@driver.browser).to be
      @driver.quit
      #access instance variable directly so we don't create a new browser instance
      expect(@driver.instance_variable_get(:@browser)).to be_nil
    end
  end
end

