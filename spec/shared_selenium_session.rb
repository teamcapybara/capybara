# frozen_string_literal: true
require 'spec_helper'
require "selenium-webdriver"

RSpec.shared_examples "Capybara::Session" do |session, mode|
  let(:session) {session}

  context 'with selenium driver' do
    before do
      @session = session
    end

    describe '#driver' do
      it "should be a selenium driver" do
        expect(@session.driver).to be_an_instance_of(Capybara::Selenium::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        expect(@session.mode).to eq(mode)
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
        @env = { 'SELENIUM_BROWSER' => @session.driver.options[:browser].to_s }
        @env['LEGACY_FIREFOX'] = 'TRUE' if mode == :selenium_firefox
      end

      after do
        Dir.chdir(@current_dir)
      end

      it "should have return code 1 when running selenium_driver_rspec_failure.rb" do
        skip if ENV['HEADLESS']
        system(@env, 'rspec spec/fixtures/selenium_driver_rspec_failure.rb', out: File::NULL, err: File::NULL)
        expect($?.exitstatus).to eq(1)
      end

      it "should have return code 0 when running selenium_driver_rspec_success.rb" do
        skip if ENV['HEADLESS']
        system(@env, 'rspec spec/fixtures/selenium_driver_rspec_success.rb', out: File::NULL, err: File::NULL)
        expect($?.exitstatus).to eq(0)
      end
    end

    describe "#accept_alert" do
      it "supports a blockless mode" do
        @session.visit('/with_js')
        skip "Headless Chrome doesn't support blockless modal methods" if @session.driver.send(:headless_chrome?)
        @session.click_link('Open alert')
        @session.accept_alert
        expect{@session.driver.browser.switch_to.alert}.to raise_error(@session.driver.send(:modal_error))
      end

      it "raises if block is missing" do
        @session.visit('/with_js')
        skip "Only Headless Chrome requires the block due to system modal JS injection" unless @session.driver.send(:headless_chrome?)
        expect { @session.accept_alert }.to raise_error(ArgumentError)
      end
    end

    context '#fill_in_with empty string and no options' do
      it 'should trigger change when clearing a field' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', with: '')
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session).to have_selector(:css, '.change_event_triggered', match: :one)
      end
    end

    context "#fill_in with { :clear => :backspace } fill_option", requires: [:js] do
      it 'should fill in a field, replacing an existing value' do
        @session.visit('/form')
        @session.fill_in('form_first_name', with: 'Harry',
                          fill_options: { clear: :backspace} )
        expect(@session.find(:fillable_field, 'form_first_name').value).to eq('Harry')
      end

      it 'should only trigger onchange once' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', with: 'some value',
                         fill_options: { :clear => :backspace })
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session.find(:css, '.change_event_triggered', match: :one)).to have_text 'some value'
      end

      it 'should trigger change when clearing field' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', with: '',
                         fill_options: { :clear => :backspace })
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session).to have_selector(:css, '.change_event_triggered', match: :one)
      end

      it 'should trigger input event field_value.length times' do
        @session.visit('/with_js')
        @session.fill_in('with_change_event', with: '',
                         fill_options: { :clear => :backspace })
        # click outside the field to trigger the change event
        @session.find(:css, 'body').click
        expect(@session).to have_xpath('//p[@class="input_event_triggered"]', count: 13)
      end
    end

    context "#fill_in with { clear: :none } fill_options" do
      it 'should append to content in a field' do
        @session.visit('/form')
        @session.fill_in('form_first_name', with: 'Harry',
                          fill_options: { clear: :none} )
        expect(@session.find(:fillable_field, 'form_first_name').value).to eq('JohnHarry')
      end
    end

    context "#fill_in with { clear: Array } fill_options" do
      it 'should pass the array through to the element' do
        pending "selenium-webdriver/geckodriver doesn't support complex sets of characters" if marionette?(@session)
        #this is mainly for use with [[:control, 'a'], :backspace] - however since that is platform dependant I'm testing with something less useful
        @session.visit('/form')
        @session.fill_in('form_first_name', with: 'Harry',
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

    describe "all with disappearing elements" do
      it "ignores stale elements in results" do
        @session.visit('/path')
        elements = @session.all(:link) { |node| raise Selenium::WebDriver::Error::StaleElementReferenceError }
        expect(elements.size).to eq 0
      end
    end

    describe "#evaluate_script" do
      it "can return an element" do
        @session.visit('/form')
        element = @session.evaluate_script("document.getElementById('form_title')")
        expect(element).to eq @session.find(:id, 'form_title')
      end

      it "can return arrays of nested elements" do
        @session.visit('/form')
        elements = @session.evaluate_script('document.querySelectorAll("#form_city option")')
        elements.each do |el|
          expect(el).to be_instance_of Capybara::Node::Element
        end
        expect(elements).to eq @session.find(:css, '#form_city').all(:css, 'option').to_a
      end

      it "can return hashes with elements" do
        @session.visit('/form')
        result = @session.evaluate_script("{ a: document.getElementById('form_title'), b: {c: document.querySelectorAll('#form_city option')}}")
        expect(result).to eq({
          'a' => @session.find(:id, 'form_title'),
          'b' => {
            'c' => @session.find(:css, '#form_city').all(:css, 'option').to_a
          }
        })
      end

      describe "#evaluate_async_script" do
        it "will timeout if the script takes too long" do
          @session.visit('/with_js')
          expect do
            @session.using_wait_time(1) do
              @session.evaluate_async_script("var cb = arguments[0]; setTimeout(function(){ cb(null) }, 3000)")
            end
          end.to raise_error Selenium::WebDriver::Error::ScriptTimeoutError
        end
      end
    end

    describe "Element#inspect" do
      it "outputs obsolete elements" do
        @session.visit('/form')
        el = @session.find(:button, 'Click me!').click
        expect(@session).to have_no_button('Click me!')
        expect(el).not_to receive(:synchronize)
        expect(el.inspect).to eq "Obsolete #<Capybara::Node::Element>"
      end
    end

    describe "Element#click" do
      it "should handle fixed headers/footers" do
        if mode == :selenium_marionette && !(ENV['TRAVIS_ALLOW_FAILURE']=='true')
          pending "geckodriver/firefox/marionette just fail to click without reporting an error - no way for us to detect/catch"
        end
        @session.visit('/with_fixed_header_footer')
        # @session.click_link('Go to root')
        @session.find(:link, 'Go to root').click
        expect(@session).to have_current_path('/')
      end
    end
  end
end
