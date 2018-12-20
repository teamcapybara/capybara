# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'

RSpec.shared_examples 'Capybara::Session' do |session, mode|
  let(:session) { session }

  context 'with selenium driver' do
    describe '#driver' do
      it 'should be a selenium driver' do
        expect(session.driver).to be_an_instance_of(Capybara::Selenium::Driver)
      end
    end

    describe '#mode' do
      it 'should remember the mode' do
        expect(session.mode).to eq(mode)
      end
    end

    describe '#reset!' do
      it 'freshly reset session should not be touched' do
        session.instance_variable_set(:@touched, true)
        session.reset!
        expect(session.instance_variable_get(:@touched)).to eq false
      end
    end

    describe 'exit codes' do
      before do
        @current_dir = Dir.getwd
        Dir.chdir(File.join(File.dirname(__FILE__), '..'))
        @env = { 'SELENIUM_BROWSER' => session.driver.options[:browser].to_s }
      end

      after do
        Dir.chdir(@current_dir)
      end

      it 'should have return code 1 when running selenium_driver_rspec_failure.rb' do
        skip 'only setup for local non-headless' if headless_or_remote?

        system(@env, 'rspec spec/fixtures/selenium_driver_rspec_failure.rb', out: File::NULL, err: File::NULL)
        expect($CHILD_STATUS.exitstatus).to eq(1)
      end

      it 'should have return code 0 when running selenium_driver_rspec_success.rb' do
        skip 'only setup for local non-headless' if headless_or_remote?

        system(@env, 'rspec spec/fixtures/selenium_driver_rspec_success.rb', out: File::NULL, err: File::NULL)
        expect($CHILD_STATUS.exitstatus).to eq(0)
      end
    end

    describe '#accept_alert', requires: [:modals] do
      it 'supports a blockless mode' do
        session.visit('/with_js')
        session.click_link('Open alert')
        session.accept_alert
        expect { session.driver.browser.switch_to.alert }.to raise_error(session.driver.send(:modal_error))
      end

      it 'can be called before visiting' do
        session.accept_alert 'Initial alert' do
          session.visit('/initial_alert')
        end
        expect(session).to have_text('Initial alert page')
      end
    end

    context '#fill_in_with empty string and no options' do
      it 'should trigger change when clearing a field' do
        session.visit('/with_js')
        session.fill_in('with_change_event', with: '')
        # click outside the field to trigger the change event
        session.find(:css, 'body').click
        expect(session).to have_selector(:css, '.change_event_triggered', match: :one)
      end
    end

    context '#fill_in with { :clear => :backspace } fill_option', requires: [:js] do
      before do
        # Firefox has an issue with change events if the main window doesn't think it's focused
        session.execute_script('window.focus()')
      end

      it 'should fill in a field, replacing an existing value' do
        session.visit('/form')
        session.fill_in('form_first_name',
                        with: 'Harry',
                        fill_options: { clear: :backspace })
        expect(session.find(:fillable_field, 'form_first_name').value).to eq('Harry')
      end

      it 'should fill in a field, replacing an existing value, even with caret position' do
        session.visit('/form')
        session.find(:css, '#form_first_name').execute_script <<-JS
          this.focus();
          this.setSelectionRange(0, 0);
        JS

        session.fill_in('form_first_name',
                        with: 'Harry',
                        fill_options: { clear: :backspace })
        expect(session.find(:fillable_field, 'form_first_name').value).to eq('Harry')
      end

      it 'should fill in if the option is set via global option' do
        Capybara.default_set_options = { clear: :backspace }
        session.visit('/form')
        session.fill_in('form_first_name', with: 'Thomas')
        expect(session.find(:fillable_field, 'form_first_name').value).to eq('Thomas')
      end

      it 'should only trigger onchange once' do
        session.visit('/with_js')
        session.fill_in('with_change_event',
                        with: 'some value',
                        fill_options: { clear: :backspace })
        # click outside the field to trigger the change event
        session.find(:css, '#with_focus_event').click
        expect(session.find(:css, '.change_event_triggered', match: :one, wait: 5)).to have_text 'some value'
      end

      it 'should trigger change when clearing field' do
        session.visit('/with_js')
        session.fill_in('with_change_event',
                        with: '',
                        fill_options: { clear: :backspace })
        # click outside the field to trigger the change event
        session.find(:css, '#with_focus_event').click
        expect(session).to have_selector(:css, '.change_event_triggered', match: :one, wait: 5)
      end

      it 'should trigger input event field_value.length times' do
        session.visit('/with_js')
        session.fill_in('with_change_event',
                        with: '',
                        fill_options: { clear: :backspace })
        # click outside the field to trigger the change event
        session.find(:css, 'body').click
        expect(session).to have_xpath('//p[@class="input_event_triggered"]', count: 13)
      end
    end

    context '#fill_in with { clear: :none } fill_options' do
      it 'should append to content in a field' do
        session.visit('/form')
        session.fill_in('form_first_name',
                        with: 'Harry',
                        fill_options: { clear: :none })
        expect(session.find(:fillable_field, 'form_first_name').value).to eq('JohnHarry')
      end
    end

    context  '#fill_in with Date' do
      before do
        session.visit('/form')
        session.find(:css, '#form_date').execute_script <<-JS
          window.capybara_formDateFiredEvents = [];
          var fd = this;
          ['focus', 'input', 'change'].forEach(function(eventType) {
            fd.addEventListener(eventType, function() { window.capybara_formDateFiredEvents.push(eventType); });
          });
        JS
        # work around weird FF issue where it would create an extra focus issue in some cases
        session.find(:css, 'body').click
      end

      it 'should generate standard events on changing value' do
        pending "IE 11 doesn't support date input type" if ie?(session)
        session.fill_in('form_date', with: Date.today)
        expect(session.evaluate_script('window.capybara_formDateFiredEvents')).to eq %w[focus input change]
      end

      it 'should not generate input and change events if the value is not changed' do
        pending "IE 11 doesn't support date input type" if ie?(session)
        session.fill_in('form_date', with: Date.today)
        session.fill_in('form_date', with: Date.today)
        # Chrome adds an extra focus for some reason - ok for now
        expect(session.evaluate_script('window.capybara_formDateFiredEvents')).to eq(%w[focus input change])
      end
    end

    context '#fill_in with { clear: Array } fill_options' do
      it 'should pass the array through to the element' do
        # this is mainly for use with [[:control, 'a'], :backspace] - however since that is platform dependant I'm testing with something less useful
        session.visit('/form')
        session.fill_in('form_first_name',
                        with: 'Harry',
                        fill_options: { clear: [[:shift, 'abc'], :backspace] })
        expect(session.find(:fillable_field, 'form_first_name').value).to eq('JohnABHarry')
      end
    end

    describe '#path' do
      it 'returns xpath' do
        # this is here because it is testing for an XPath that is specific to the algorithm used in the selenium driver
        session.visit('/path')
        element = session.find(:link, 'Second Link')
        expect(element.path).to eq('/HTML/BODY[1]/DIV[2]/A[1]')
      end

      it 'handles namespaces in xhtml' do
        pending "IE 11 doesn't handle all XPath querys (namespace-uri, etc)" if ie?(session)
        session.visit '/with_namespace'
        rect = session.find(:css, 'div svg rect:first-of-type')
        expect(rect.path).to eq("/HTML/BODY[1]/DIV[1]/*[local-name()='svg' and namespace-uri()='http://www.w3.org/2000/svg'][1]/*[local-name()='rect' and namespace-uri()='http://www.w3.org/2000/svg'][1]")
        expect(session.find(:xpath, rect.path)).to eq rect
      end

      it 'handles default namespaces in html5' do
        pending "IE 11 doesn't handle all XPath querys (namespace-uri, etc)" if ie?(session)
        session.visit '/with_html5_svg'
        rect = session.find(:css, 'div svg rect:first-of-type')
        expect(rect.path).to eq("/HTML/BODY[1]/DIV[1]/*[local-name()='svg' and namespace-uri()='http://www.w3.org/2000/svg'][1]/*[local-name()='rect' and namespace-uri()='http://www.w3.org/2000/svg'][1]")
        expect(session.find(:xpath, rect.path)).to eq rect
      end

      it 'handles case sensitive element names' do
        pending "IE 11 doesn't handle all XPath querys (namespace-uri, etc)" if ie?(session)
        session.visit '/with_namespace'
        els = session.all(:css, 'div *', visible: :all)
        expect { els.map(&:path) }.not_to raise_error
        lg = session.find(:css, 'div linearGradient', visible: :all)
        expect(session.find(:xpath, lg.path, visible: :all)).to eq lg
      end
    end

    describe 'all with disappearing elements' do
      it 'ignores stale elements in results' do
        session.visit('/path')
        elements = session.all(:link) { |_node| raise Selenium::WebDriver::Error::StaleElementReferenceError }
        expect(elements.size).to eq 0
      end
    end

    describe '#evaluate_script' do
      it 'can return an element' do
        session.visit('/form')
        element = session.evaluate_script("document.getElementById('form_title')")
        expect(element).to eq session.find(:id, 'form_title')
      end

      it 'can return arrays of nested elements' do
        session.visit('/form')
        elements = session.evaluate_script('document.querySelectorAll("#form_city option")')
        expect(elements).to all(be_instance_of Capybara::Node::Element)
        expect(elements).to eq session.find(:css, '#form_city').all(:css, 'option').to_a
      end

      it 'can return hashes with elements' do
        session.visit('/form')
        result = session.evaluate_script("{ a: document.getElementById('form_title'), b: {c: document.querySelectorAll('#form_city option')}}")
        expect(result).to eq(
          'a' => session.find(:id, 'form_title'),
          'b' => {
            'c' => session.find(:css, '#form_city').all(:css, 'option').to_a
          }
        )
      end

      describe '#evaluate_async_script' do
        it 'will timeout if the script takes too long' do
          session.visit('/with_js')
          expect do
            session.using_wait_time(1) do
              session.evaluate_async_script('var cb = arguments[0]; setTimeout(function(){ cb(null) }, 3000)')
            end
          end.to raise_error Selenium::WebDriver::Error::ScriptTimeoutError
        end
      end
    end

    describe 'Element#inspect' do
      it 'outputs obsolete elements' do
        session.visit('/form')
        el = session.find(:button, 'Click me!').click
        expect(session).to have_no_button('Click me!')
        allow(el).to receive(:synchronize)
        expect(el.inspect).to eq 'Obsolete #<Capybara::Node::Element>'
        expect(el).not_to have_received(:synchronize)
      end
    end

    describe 'Element#click' do
      it 'should handle fixed headers/footers' do
        session.visit('/with_fixed_header_footer')
        # session.click_link('Go to root')
        session.find(:link, 'Go to root').click
        expect(session).to have_current_path('/')
      end
    end

    describe 'Element#drag_to' do
      before do
        skip "Firefox < 62 doesn't support a DataTransfer constuctor" if firefox_lt?(62.0, session)
        skip "IE doesn't support a DataTransfer constuctor" if ie?(session)
      end

      it 'should HTML5 drag and drop an object' do
        session.visit('/with_js')
        element = session.find('//div[@id="drag_html5"]')
        target = session.find('//div[@id="drop_html5"]')
        element.drag_to(target)
        expect(session).to have_xpath('//div[contains(., "HTML5 Dropped drag_html5")]')
      end

      it 'should not HTML5 drag and drop on a non HTML5 drop element' do
        session.visit('/with_js')
        element = session.find('//div[@id="drag_html5"]')
        target = session.find('//div[@id="drop_html5"]')
        target.execute_script("$(this).removeClass('drop');")
        element.drag_to(target)
        sleep 1
        expect(session).not_to have_xpath('//div[contains(., "HTML5 Dropped drag_html5")]')
      end

      it 'should HTML5 drag and drop when scrolling needed' do
        session.visit('/with_js')
        element = session.find('//div[@id="drag_html5_scroll"]')
        target = session.find('//div[@id="drop_html5_scroll"]')
        element.drag_to(target)
        expect(session).to have_xpath('//div[contains(., "HTML5 Dropped drag_html5_scroll")]')
      end

      it 'should drag HTML5 default draggable elements' do
        session.visit('/with_js')
        link = session.find_link('drag_link_html5')
        target = session.find(:id, 'drop_html5')
        link.drag_to target
        expect(session).to have_xpath('//div[contains(., "HTML5 Dropped")]')
      end
    end

    describe 'Capybara#Node#attach_file' do
      it 'can attach a directory' do
        pending "Geckodriver doesn't support uploading a directory" if firefox?(session)
        pending "Selenium remote doesn't support transferring a directory" if remote?(session)
        pending "Headless Chrome doesn't support directory upload - https://bugs.chromium.org/p/chromedriver/issues/detail?id=2521&q=directory%20upload&colspec=ID%20Status%20Pri%20Owner%20Summary" if chrome?(session) && ENV['HEADLESS']
        pending "IE doesn't support uploading a directory" if ie?(session)

        session.visit('/form')
        @test_file_dir = File.expand_path('./fixtures', File.dirname(__FILE__))
        session.attach_file('Directory Upload', @test_file_dir)
        session.click_button('Upload Multiple')
        expect(session.body).to include('5 | ') # number of files
      end
    end

    context 'Windows' do
      it "can't close the primary window" do
        expect do
          session.current_window.close
        end.to raise_error(ArgumentError, 'Not allowed to close the primary window')
      end
    end

    describe 'Capybara#disable_animation' do
      context 'when set to `true`' do
        before(:context) do # rubocop:disable RSpec/BeforeAfterAll
          # NOTE: Although Capybara.SpecHelper.reset! sets Capybara.disable_animation to false,
          # it doesn't affect any of these tests because the settings are applied per-session
          Capybara.disable_animation = true
          @animation_session = Capybara::Session.new(session.mode, TestApp.new)
        end

        after(:context) do # rubocop:disable RSpec/BeforeAfterAll
          @animation_session = nil
        end

        it 'should disable CSS transitions' do
          @animation_session.visit('with_animation')
          @animation_session.click_link('transition me away')
          expect(@animation_session).to have_no_link('transition me away', wait: 0.5)
        end

        it 'should disable CSS animations' do
          @animation_session.visit('with_animation')
          @animation_session.click_link('animate me away')
          expect(@animation_session).to have_no_link('animate me away', wait: 0.5)
        end
      end

      context 'if we pass in css that matches elements' do
        before(:context) do # rubocop:disable RSpec/BeforeAfterAll
          # NOTE: Although Capybara.SpecHelper.reset! sets Capybara.disable_animation to false,
          # it doesn't affect any of these tests because the settings are applied per-session
          Capybara.disable_animation = '#with_animation a'
          @animation_session_with_matching_css = Capybara::Session.new(session.mode, TestApp.new)
        end

        after(:context) do # rubocop:disable RSpec/BeforeAfterAll
          @animation_session_with_matching_css = nil
        end

        it 'should disable CSS transitions' do
          @animation_session_with_matching_css.visit('with_animation')
          @animation_session_with_matching_css.click_link('transition me away')
          expect(@animation_session_with_matching_css).to have_no_link('transition me away', wait: 0.5)
        end

        it 'should disable CSS animations' do
          @animation_session_with_matching_css.visit('with_animation')
          @animation_session_with_matching_css.click_link('animate me away')
          expect(@animation_session_with_matching_css).to have_no_link('animate me away', wait: 0.5)
        end
      end

      context 'if we pass in css that does not match elements' do
        before(:context) do # rubocop:disable RSpec/BeforeAfterAll
          # NOTE: Although Capybara.SpecHelper.reset! sets Capybara.disable_animation to false,
          # it doesn't affect any of these tests because the settings are applied per-session
          Capybara.disable_animation = '.this-class-matches-nothing'
          @animation_session_without_matching_css = Capybara::Session.new(session.mode, TestApp.new)
        end

        after(:context) do # rubocop:disable RSpec/BeforeAfterAll
          @animation_session_without_matching_css = nil
        end

        it 'should not disable CSS transitions' do
          @animation_session_without_matching_css.visit('with_animation')
          @animation_session_without_matching_css.click_link('transition me away')
          sleep 0.5 # Wait long enough for click to have been processed
          expect(@animation_session_without_matching_css).to have_link('transition me away', wait: false)
          expect(@animation_session_without_matching_css).to have_no_link('transition me away', wait: 5)
        end

        it 'should not disable CSS animations' do
          @animation_session_without_matching_css.visit('with_animation')
          @animation_session_without_matching_css.click_link('animate me away')
          sleep 0.5 # Wait long enough for click to have been processed
          expect(@animation_session_without_matching_css).to have_link('animate me away', wait: false)
          expect(@animation_session_without_matching_css).to have_no_link('animate me away', wait: 5)
        end
      end
    end

    describe ':element selector' do
      it 'can find html5 svg elements' do
        session.visit('with_html5_svg')
        expect(session).to have_selector(:element, :svg)
        expect(session).to have_selector(:element, :rect, visible: true)
        expect(session).to have_selector(:element, :circle)
        expect(session).to have_selector(:element, :linearGradient, visible: :all)
      end

      it 'can query attributes with strange characters' do
        session.visit('/form')
        expect(session).to have_selector(:element, "{custom}": true)
        expect(session).to have_selector(:element, "{custom}": 'abcdef')
      end
    end
  end

  def headless_or_remote?
    !ENV['HEADLESS'].nil? || session.driver.options[:browser] == :remote
  end
end
