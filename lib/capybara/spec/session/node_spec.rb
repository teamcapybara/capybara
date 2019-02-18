# frozen_string_literal: true

# Note: This file uses `sleep` to sync up parts of the tests. This is only implemented like this
# because of the methods being tested. In tests using Capybara this type of behavior should be implemented
# using Capybara provided assertions with builtin waiting behavior.

Capybara::SpecHelper.spec 'node' do
  before do
    @session.visit('/with_html')
  end

  it 'should act like a session object' do
    @session.visit('/form')
    @form = @session.find(:css, '#get-form')
    expect(@form).to have_field('Middle Name')
    expect(@form).to have_no_field('Languages')
    @form.fill_in('Middle Name', with: 'Monkey')
    @form.click_button('med')
    expect(extract_results(@session)['middle_name']).to eq('Monkey')
  end

  it 'should scope CSS selectors' do
    expect(@session.find(:css, '#second')).to have_no_css('h1')
  end

  describe '#query_scope' do
    it 'should have a reference to the element the query was evaluated on if there is one' do
      @node = @session.find(:css, '#first')
      expect(@node.query_scope).to eq(@node.session.document)
      expect(@node.find(:css, '#foo').query_scope).to eq(@node)
    end
  end

  describe '#text' do
    it 'should extract node texts' do
      expect(@session.all('//a')[0].text).to eq('labore')
      expect(@session.all('//a')[1].text).to eq('ullamco')
    end

    it 'should return document text on /html selector' do
      @session.visit('/with_simple_html')
      expect(@session.all('/html')[0].text).to eq('Bar')
    end
  end

  describe '#[]' do
    it 'should extract node attributes' do
      expect(@session.all('//a')[0][:class]).to eq('simple')
      expect(@session.all('//a')[1][:id]).to eq('foo')
      expect(@session.all('//input')[0][:type]).to eq('text')
    end

    it 'should extract boolean node attributes' do
      expect(@session.find('//input[@id="checked_field"]')[:checked]).to be_truthy
    end
  end

  describe '#style', requires: [:css] do
    it 'should return the computed style value' do
      expect(@session.find(:css, '#first').style('display')).to eq('display' => 'block')
      expect(@session.find(:css, '#second').style(:display)).to eq('display' => 'inline')
    end

    it 'should return multiple style values' do
      expect(@session.find(:css, '#first').style('display', :'line-height')).to eq('display' => 'block', 'line-height' => '25px')
    end
  end

  describe '#value' do
    it 'should allow retrieval of the value' do
      expect(@session.find('//textarea[@id="normal"]').value).to eq('banana')
    end

    it 'should not swallow extra newlines in textarea' do
      expect(@session.find('//textarea[@id="additional_newline"]').value).to eq("\nbanana")
    end

    it 'should not swallow leading newlines for set content in textarea' do
      @session.find('//textarea[@id="normal"]').set("\nbanana")
      expect(@session.find('//textarea[@id="normal"]').value).to eq("\nbanana")
    end

    it 'return any HTML content in textarea' do
      @session.find('//textarea[1]').set('some <em>html</em> here')
      expect(@session.find('//textarea[1]').value).to eq('some <em>html</em> here')
    end

    it "defaults to 'on' for checkbox" do
      @session.visit('/form')
      expect(@session.find('//input[@id="valueless_checkbox"]').value).to eq('on')
    end

    it "defaults to 'on' for radio buttons" do
      @session.visit('/form')
      expect(@session.find('//input[@id="valueless_radio"]').value).to eq('on')
    end
  end

  describe '#set' do
    it 'should allow assignment of field value' do
      expect(@session.first('//input').value).to eq('monkey')
      @session.first('//input').set('gorilla')
      expect(@session.first('//input').value).to eq('gorilla')
    end

    it 'should fill the field even if the caret was not at the end', requires: [:js] do
      @session.execute_script("var el = document.getElementById('test_field'); el.focus(); el.setSelectionRange(0, 0);")
      @session.first('//input').set('')
      expect(@session.first('//input').value).to eq('')
    end

    it 'should raise if the text field is readonly' do
      expect { @session.first('//input[@readonly]').set('changed') }.to raise_error(Capybara::ReadOnlyElementError)
    end

    it 'should raise if the textarea is readonly' do
      expect { @session.first('//textarea[@readonly]').set('changed') }.to raise_error(Capybara::ReadOnlyElementError)
    end

    it 'should use global default options' do
      Capybara.default_set_options = { clear: :backspace }
      element = @session.first(:fillable_field, type: 'text')
      allow(element.base).to receive(:set)
      element.set('gorilla')
      expect(element.base).to have_received(:set).with('gorilla', clear: :backspace)
    end

    context 'with a contenteditable element', requires: [:js] do
      it 'should allow me to change the contents' do
        @session.visit('/with_js')
        @session.find(:css, '#existing_content_editable').set('WYSIWYG')
        expect(@session.find(:css, '#existing_content_editable').text).to eq('WYSIWYG')
      end

      it 'should allow me to set the contents' do
        @session.visit('/with_js')
        @session.find(:css, '#blank_content_editable').set('WYSIWYG')
        expect(@session.find(:css, '#blank_content_editable').text).to eq('WYSIWYG')
      end

      it 'should allow me to change the contents of a child element' do
        @session.visit('/with_js')
        @session.find(:css, '#existing_content_editable_child').set('WYSIWYG')
        expect(@session.find(:css, '#existing_content_editable_child').text).to eq('WYSIWYG')
        expect(@session.find(:css, '#existing_content_editable_child_parent').text).to eq("Some content\nWYSIWYG")
      end
    end
  end

  describe '#tag_name' do
    it 'should extract node tag name' do
      expect(@session.all('//a')[0].tag_name).to eq('a')
      expect(@session.all('//a')[1].tag_name).to eq('a')
      expect(@session.all('//p')[1].tag_name).to eq('p')
    end
  end

  describe '#disabled?' do
    it 'should extract disabled node' do
      @session.visit('/form')
      expect(@session.find('//input[@id="customer_name"]')).to be_disabled
      expect(@session.find('//input[@id="customer_email"]')).not_to be_disabled
    end

    it 'should see disabled options as disabled' do
      @session.visit('/form')
      expect(@session.find('//select[@id="form_title"]/option[1]')).not_to be_disabled
      expect(@session.find('//select[@id="form_title"]/option[@disabled]')).to be_disabled
    end

    it 'should see enabled options in disabled select as disabled' do
      @session.visit('/form')
      expect(@session.find('//select[@id="form_disabled_select"]/option')).to be_disabled
      expect(@session.find('//select[@id="form_disabled_select"]/optgroup/option')).to be_disabled
      expect(@session.find('//select[@id="form_title"]/option[1]')).not_to be_disabled
    end

    it 'should see enabled options in disabled optgroup as disabled' do
      @session.visit('/form')
      expect(@session.find('//option', text: 'A.B.1')).to be_disabled
      expect(@session.find('//option', text: 'A.2')).not_to be_disabled
    end

    it 'should see a disabled fieldset as disabled' do
      @session.visit('/form')
      expect(@session.find(:css, '#form_disabled_fieldset')).to be_disabled
    end

    context 'in a disabled fieldset' do
      # https://html.spec.whatwg.org/#the-fieldset-element
      it 'should see elements not in first legend as disabled' do
        @session.visit('/form')
        expect(@session.find('//input[@id="form_disabled_fieldset_child"]')).to be_disabled
        expect(@session.find('//input[@id="form_disabled_fieldset_second_legend_child"]')).to be_disabled
        expect(@session.find('//input[@id="form_enabled_fieldset_child"]')).not_to be_disabled
      end

      it 'should see elements in first legend as enabled' do
        @session.visit('/form')
        expect(@session.find('//input[@id="form_disabled_fieldset_legend_child"]')).not_to be_disabled
      end

      it 'should sees options not in first legend as disabled' do
        @session.visit('/form')
        expect(@session.find('//option', text: 'Disabled Child Option')).to be_disabled
      end
    end

    it 'should be boolean' do
      @session.visit('/form')
      expect(@session.find('//select[@id="form_disabled_select"]/option').disabled?).to be true
      expect(@session.find('//select[@id="form_disabled_select2"]/option').disabled?).to be true
      expect(@session.find('//select[@id="form_title"]/option[1]').disabled?).to be false
    end

    it 'should be disabled for all elements that are CSS :disabled' do
      @session.visit('/form')
      # sanity check
      expect(@session.all(:css, ':disabled')).to all(be_disabled)
    end
  end

  describe '#visible?' do
    it 'should extract node visibility' do
      Capybara.ignore_hidden_elements = false
      expect(@session.first('//a')).to be_visible

      expect(@session.find('//div[@id="hidden"]')).not_to be_visible
      expect(@session.find('//div[@id="hidden_via_ancestor"]')).not_to be_visible
      expect(@session.find('//div[@id="hidden_attr"]')).not_to be_visible
      expect(@session.find('//a[@id="hidden_attr_via_ancestor"]')).not_to be_visible
      expect(@session.find('//input[@id="hidden_input"]')).not_to be_visible
    end

    it 'should be boolean' do
      Capybara.ignore_hidden_elements = false
      expect(@session.first('//a').visible?).to be true
      expect(@session.find('//div[@id="hidden"]').visible?).to be false
    end
  end

  describe '#checked?' do
    it 'should extract node checked state' do
      @session.visit('/form')
      expect(@session.find('//input[@id="gender_female"]')).to be_checked
      expect(@session.find('//input[@id="gender_male"]')).not_to be_checked
      expect(@session.first('//h1')).not_to be_checked
    end

    it 'should be boolean' do
      @session.visit('/form')
      expect(@session.find('//input[@id="gender_female"]').checked?).to be true
      expect(@session.find('//input[@id="gender_male"]').checked?).to be false
      expect(@session.find('//input[@id="no_attr_value_checked"]').checked?).to be true
    end
  end

  describe '#selected?' do
    it 'should extract node selected state' do
      @session.visit('/form')
      expect(@session.find('//option[@value="en"]')).to be_selected
      expect(@session.find('//option[@value="sv"]')).not_to be_selected
      expect(@session.first('//h1')).not_to be_selected
    end

    it 'should be boolean' do
      @session.visit('/form')
      expect(@session.find('//option[@value="en"]').selected?).to be true
      expect(@session.find('//option[@value="sv"]').selected?).to be false
      expect(@session.first('//h1').selected?).to be false
    end
  end

  describe '#==' do
    it 'preserve object identity' do
      expect(@session.find('//h1') == @session.find('//h1')).to be true # rubocop:disable Lint/UselessComparison
      expect(@session.find('//h1') === @session.find('//h1')).to be true # rubocop:disable Style/CaseEquality, Lint/UselessComparison
      expect(@session.find('//h1').eql?(@session.find('//h1'))).to be false
    end

    it 'returns false for unrelated object' do
      expect(@session.find('//h1') == 'Not Capybara::Node::Base').to be false
    end
  end

  describe '#path' do
    # Testing for specific XPaths here doesn't make sense since there
    # are many that can refer to the same element
    before do
      @session.visit('/path')
    end

    it 'returns xpath which points to itself' do
      element = @session.find(:link, 'Second Link')
      expect(@session.find(:xpath, element.path)).to eq(element)
    end
  end

  describe '#trigger', requires: %i[js trigger] do
    it 'should allow triggering of custom JS events' do
      @session.visit('/with_js')
      @session.find(:css, '#with_focus_event').trigger(:focus)
      expect(@session).to have_css('#focus_event_triggered')
    end
  end

  describe '#drag_to', requires: %i[js drag] do
    it 'should drag and drop an object' do
      @session.visit('/with_js')
      element = @session.find('//div[@id="drag"]')
      target = @session.find('//div[@id="drop"]')
      element.drag_to(target)
      expect(@session).to have_xpath('//div[contains(., "Dropped!")]')
    end

    it 'should drag and drop if scrolling is needed' do
      @session.visit('/with_js')
      element = @session.find('//div[@id="drag_scroll"]')
      target = @session.find('//div[@id="drop_scroll"]')
      element.drag_to(target)
      expect(@session).to have_xpath('//div[contains(., "Dropped!")]')
    end

    it 'should drag a link' do
      @session.visit('/with_js')
      link = @session.find_link('drag_link')
      target = @session.find(:id, 'drop')
      link.drag_to target
      expect(@session).to have_xpath('//div[contains(., "Dropped!")]')
    end
  end

  describe '#hover', requires: [:hover] do
    it 'should allow hovering on an element' do
      @session.visit('/with_hover')
      expect(@session.find(:css, '.wrapper:not(.scroll_needed) .hidden_until_hover', visible: false)).not_to be_visible
      @session.find(:css, '.wrapper:not(.scroll_needed)').hover
      expect(@session.find(:css, '.wrapper:not(.scroll_needed) .hidden_until_hover', visible: false)).to be_visible
    end

    it 'should allow hovering on an element that needs to be scrolled into view' do
      @session.visit('/with_hover')
      expect(@session.find(:css, '.wrapper.scroll_needed .hidden_until_hover', visible: false)).not_to be_visible
      @session.find(:css, '.wrapper.scroll_needed').hover
      expect(@session.find(:css, '.wrapper.scroll_needed .hidden_until_hover', visible: false)).to be_visible
    end

    it 'should hover again after following a link and back' do
      @session.visit('/with_hover')
      @session.find(:css, '.wrapper:not(.scroll_needed)').hover
      @session.click_link('Other hover page')
      @session.click_link('Go back')
      @session.find(:css, '.wrapper:not(.scroll_needed)').hover
      expect(@session.find(:css, '.wrapper:not(.scroll_needed) .hidden_until_hover', visible: false)).to be_visible
    end
  end

  describe '#click' do
    it 'should not follow a link if no href' do
      @session.find(:css, '#link_placeholder').click
      expect(@session.current_url).to match(%r{/with_html$})
    end

    it 'should go to the same page if href is blank' do
      @session.find(:css, '#link_blank_href').click
      sleep 1
      expect(@session).to have_current_path('/with_html')
    end

    it 'should be able to check a checkbox' do
      @session.visit('form')
      cbox = @session.find(:checkbox, 'form_terms_of_use')
      expect(cbox).not_to be_checked
      cbox.click
      expect(cbox).to be_checked
    end

    it 'should be able to uncheck a checkbox' do
      @session.visit('/form')
      cbox = @session.find(:checkbox, 'form_pets_dog')
      expect(cbox).to be_checked
      cbox.click
      expect(cbox).not_to be_checked
    end

    it 'should be able to select a radio button' do
      @session.visit('/form')
      radio = @session.find(:radio_button, 'gender_male')
      expect(radio).not_to be_checked
      radio.click
      expect(radio).to be_checked
    end

    it 'should allow modifiers', requires: [:js] do
      @session.visit('/with_js')
      @session.find(:css, '#click-test').click(:shift)
      expect(@session).to have_link('Has been shift clicked')
    end

    it 'should allow multiple modifiers', requires: [:js] do
      @session.visit('with_js')
      @session.find(:css, '#click-test').click(:control, :alt, :meta, :shift)
      # Selenium with Chrome on OSX ctrl-click generates a right click so just verify all keys but not click type
      expect(@session).to have_link('alt control meta shift')
    end

    it 'should allow to adjust the click offset', requires: [:js] do
      @session.visit('with_js')
      @session.find(:css, '#click-test').click(x: 5, y: 5)
      link = @session.find(:link, 'has-been-clicked')
      locations = link.text.match(/^Has been clicked at (?<x>[\d\.-]+),(?<y>[\d\.-]+)$/)
      # Resulting click location should be very close to 0, 0 relative to top left corner of the element, but may not be exact due to
      # integer/float conversions and rounding.
      expect(locations[:x].to_f).to be_within(1).of(5)
      expect(locations[:y].to_f).to be_within(1).of(5)
    end

    it 'should raise error if both x and y values are not passed' do
      @session.visit('with_js')
      el = @session.find(:css, '#click-test')
      expect { el.click(x: 5) }.to raise_error ArgumentError
      expect { el.click(x: nil, y: 3) }.to raise_error ArgumentError
    end

    it 'should be able to click a table row', requires: [:js] do
      @session.visit('/tables')
      tr = @session.find(:css, '#agent_table tr:first-child').click
      expect(tr).to have_css('label', text: 'Clicked')
    end

    it 'should retry clicking', requires: [:js] do
      @session.visit('/obscured')
      obscured = @session.find(:css, '#obscured')
      @session.execute_script <<~JS
        setTimeout(function(){ $('#cover').hide(); }, 700)
      JS
      expect { obscured.click }.not_to raise_error
    end

    it 'should allow to retry longer', requires: [:js] do
      @session.visit('/obscured')
      obscured = @session.find(:css, '#obscured')
      @session.execute_script <<~JS
        setTimeout(function(){ $('#cover').hide(); }, 3000)
      JS
      expect { obscured.click(wait: 4) }.not_to raise_error
    end

    it 'should not retry clicking when wait is disabled', requires: [:js] do
      @session.visit('/obscured')
      obscured = @session.find(:css, '#obscured')
      @session.execute_script <<~JS
        setTimeout(function(){ $('#cover').hide(); }, 2000)
      JS
      expect { obscured.click(wait: 0) }.to(raise_error { |e| expect(e).to be_an_invalid_element_error(@session) })
    end
  end

  describe '#double_click', requires: [:js] do
    it 'should double click an element' do
      @session.visit('/with_js')
      @session.find(:css, '#click-test').double_click
      expect(@session.find(:css, '#has-been-double-clicked')).to be_truthy
    end

    it 'should allow modifiers', requires: [:js] do
      @session.visit('/with_js')
      @session.find(:css, '#click-test').double_click(:alt)
      expect(@session).to have_link('Has been alt double clicked')
    end

    it 'should allow to adjust the offset', requires: [:js] do
      @session.visit('with_js')
      @session.find(:css, '#click-test').double_click(x: 10, y: 5)
      link = @session.find(:link, 'has-been-double-clicked')
      locations = link.text.match(/^Has been double clicked at (?<x>[\d\.-]+),(?<y>[\d\.-]+)$/)
      # Resulting click location should be very close to 10, 5 relative to top left corner of the element, but may not be exact due
      # to integer/float conversions and rounding.
      expect(locations[:x].to_f).to be_within(1).of(10)
      expect(locations[:y].to_f).to be_within(1).of(5)
    end

    it 'should retry clicking', requires: [:js] do
      @session.visit('/obscured')
      obscured = @session.find(:css, '#obscured')
      @session.execute_script <<~JS
        setTimeout(function(){ $('#cover').hide(); }, 700)
      JS
      expect { obscured.double_click }.not_to raise_error
    end
  end

  describe '#right_click', requires: [:js] do
    it 'should right click an element' do
      @session.visit('/with_js')
      @session.find(:css, '#click-test').right_click
      expect(@session.find(:css, '#has-been-right-clicked')).to be_truthy
    end

    it 'should allow modifiers', requires: [:js] do
      @session.visit('/with_js')
      @session.find(:css, '#click-test').right_click(:meta)
      expect(@session).to have_link('Has been meta right clicked')
    end

    it 'should allow to adjust the offset', requires: [:js] do
      @session.visit('with_js')
      @session.find(:css, '#click-test').right_click(x: 10, y: 10)
      link = @session.find(:link, 'has-been-right-clicked')
      locations = link.text.match(/^Has been right clicked at (?<x>[\d\.-]+),(?<y>[\d\.-]+)$/)
      # Resulting click location should be very close to 10, 10 relative to top left corner of the element, but may not be exact due
      # to integer/float conversions and rounding
      expect(locations[:x].to_f).to be_within(1).of(10)
      expect(locations[:y].to_f).to be_within(1).of(10)
    end

    it 'should retry clicking', requires: [:js] do
      @session.visit('/obscured')
      obscured = @session.find(:css, '#obscured')
      @session.execute_script <<~JS
        setTimeout(function(){ $('#cover').hide(); }, 700)
      JS
      expect { obscured.right_click }.not_to raise_error
    end
  end

  describe '#send_keys', requires: [:send_keys] do
    it 'should send a string of keys to an element' do
      @session.visit('/form')
      @session.find(:css, '#address1_city').send_keys('Oceanside')
      expect(@session.find(:css, '#address1_city').value).to eq 'Oceanside'
    end

    it 'should send special characters' do
      @session.visit('/form')
      @session.find(:css, '#address1_city').send_keys('Ocean', :space, 'sie', :left, 'd')
      expect(@session.find(:css, '#address1_city').value).to eq 'Ocean side'
    end

    it 'should allow for multiple simultaneous keys' do
      @session.visit('/form')
      @session.find(:css, '#address1_city').send_keys([:shift, 'o'], 'ceanside')
      expect(@session.find(:css, '#address1_city').value).to eq 'Oceanside'
    end

    it 'should hold modifiers at top level' do
      @session.visit('/form')
      @session.find(:css, '#address1_city').send_keys('ocean', :shift, 'side')
      expect(@session.find(:css, '#address1_city').value).to eq 'oceanSIDE'
    end

    it 'should generate key events', requires: %i[send_keys js] do
      @session.visit('/with_js')
      @session.find(:css, '#with-key-events').send_keys([:shift, 't'], [:shift, 'w'])
      expect(@session.find(:css, '#key-events-output')).to have_text('keydown:16 keydown:84 keydown:16 keydown:87')
    end
  end

  describe '#execute_script', requires: %i[js es_args] do
    it 'should execute the given script in the context of the element and return nothing' do
      @session.visit('/with_js')
      expect(@session.find(:css, '#change').execute_script("this.textContent = 'Funky Doodle'")).to be_nil
      expect(@session).to have_css('#change', text: 'Funky Doodle')
    end

    it 'should pass arguments to the script' do
      @session.visit('/with_js')
      @session.find(:css, '#change').execute_script('this.textContent = arguments[0]', 'Doodle Funk')
      expect(@session).to have_css('#change', text: 'Doodle Funk')
    end
  end

  describe '#evaluate_script', requires: %i[js es_args] do
    it 'should evaluate the given script in the context of the element and  return whatever it produces' do
      @session.visit('/with_js')
      el = @session.find(:css, '#with_change_event')
      expect(el.evaluate_script('this.value')).to eq('default value')
    end

    it 'should ignore leading whitespace' do
      @session.visit('/with_js')
      expect(@session.find(:css, '#change').evaluate_script('
        2 + 3
      ')).to eq 5
    end

    it 'should pass arguments to the script' do
      @session.visit('/with_js')
      @session.find(:css, '#change').evaluate_script('this.textContent = arguments[0]', 'Doodle Funk')
      expect(@session).to have_css('#change', text: 'Doodle Funk')
    end

    it 'should pass multiple arguments' do
      @session.visit('/with_js')
      change = @session.find(:css, '#change')
      expect(change.evaluate_script('arguments[0] + arguments[1]', 2, 3)).to eq 5
    end

    it 'should support returning elements' do
      @session.visit('/with_js')
      change = @session.find(:css, '#change') # ensure page has loaded and element is available
      el = change.evaluate_script('this')
      expect(el).to be_instance_of(Capybara::Node::Element)
      expect(el).to eq(change)
    end
  end

  describe '#evaluate_async_script', requires: %i[js es_args] do
    it 'should evaluate the given script in the context of the element' do
      @session.visit('/with_js')
      el = @session.find(:css, '#with_change_event')
      expect(el.evaluate_async_script('arguments[0](this.value)')).to eq('default value')
    end

    it 'should support returning elements after asynchronous operation' do
      @session.visit('/with_js')
      change = @session.find(:css, '#change') # ensure page has loaded and element is available
      el = change.evaluate_async_script('var cb = arguments[0]; setTimeout(function(el){ cb(el) }, 100, this)')
      expect(el).to eq(change)
    end
  end

  describe '#reload', requires: [:js] do
    context 'without automatic reload' do
      before { Capybara.automatic_reload = false }

      after { Capybara.automatic_reload = true }

      it 'should reload the current context of the node' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        expect(node.reload.text).to eq('has been reloaded')
        expect(node.text).to eq('has been reloaded')
      end

      it 'should reload a parent node' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me').find(:css, 'em')
        @session.click_link('Reload!')
        sleep(0.3)
        expect(node.reload.text).to eq('has been reloaded')
        expect(node.text).to eq('has been reloaded')
      end

      it 'should not automatically reload' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(0.3)
        expect do
          expect(node).to have_text('has been reloaded')
        end.to(raise_error do |error|
          expect(error).to be_an_invalid_element_error(@session)
        end)
      end
    end

    context 'with automatic reload' do
      before do
        Capybara.default_max_wait_time = 4
      end

      it 'should reload the current context of the node automatically' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(1)
        expect(node.text).to eq('has been reloaded')
      end

      it 'should reload a parent node automatically' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me').find(:css, 'em')
        @session.click_link('Reload!')
        sleep(1)
        expect(node.text).to eq('has been reloaded')
      end

      it 'should reload a node automatically when using find' do
        @session.visit('/with_js')
        node = @session.find(:css, '#reload-me')
        @session.click_link('Reload!')
        sleep(1)
        expect(node.find(:css, 'a').text).to eq('has been reloaded')
      end

      it "should not reload nodes which haven't been found with reevaluateable queries" do
        @session.visit('/with_js')
        node = @session.all(:css, '#the-list li')[1]
        @session.click_link('Fetch new list!')
        sleep(1)

        expect do
          expect(node).to have_text('Foo')
        end.to(raise_error { |error| expect(error).to be_an_invalid_element_error(@session) })
        expect do
          expect(node).to have_text('Bar')
        end.to(raise_error { |error| expect(error).to be_an_invalid_element_error(@session) })
      end

      it 'should reload nodes with options' do
        @session.visit('/with_js')
        node = @session.find(:css, 'em', text: 'reloaded')
        @session.click_link('Reload!')
        sleep(1)
        expect(node.text).to eq('has been reloaded')
      end
    end
  end

  context 'when #synchronize raises server errors' do
    it 'sets an explanatory exception as the cause of server exceptions', requires: %i[server js] do
      quietly { @session.visit('/error') }
      expect do
        @session.find(:css, 'span')
      end.to(raise_error(TestApp::TestAppError) do |e|
        expect(e.cause).to be_a Capybara::CapybaraError
        expect(e.cause.message).to match(/Your application server raised an error/)
      end)
    end

    it 'sets an explanatory exception as the cause of server exceptions with errors with initializers', requires: %i[server js] do
      quietly { @session.visit('/other_error') }
      expect do
        @session.find(:css, 'span')
      end.to(raise_error(TestApp::TestAppOtherError) do |e|
        expect(e.cause).to be_a Capybara::CapybaraError
        expect(e.cause.message).to match(/Your application server raised an error/)
      end)
    end
  end
end
