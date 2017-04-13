# frozen_string_literal: true
require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

RSpec.shared_examples Capybara::RSpecMatchers do |session, mode|

  include Capybara::DSL
  include Capybara::RSpecMatchers

  describe "have_css matcher" do
    it "gives proper description" do
      expect(have_css('h1').description).to eq("have css \"h1\"")
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          expect("<h1>Text</h1>").to have_css('h1')
        end

        it "fails if has_css? returns false" do
          expect do
            expect("<h1>Text</h1>").to have_css('h2')
          end.to raise_error(/expected to find css "h2" but there were no matches/)
        end

        it "passes if matched node count equals expected count" do
          expect("<h1>Text</h1>").to have_css('h1', count: 1)
        end

        it "fails if matched node count does not equal expected count" do
          expect do
            expect("<h1>Text</h1>").to have_css('h1', count: 2)
          end.to raise_error("expected to find css \"h1\" 2 times, found 1 match: \"Text\"")
        end

        it "fails if matched node count is less than expected minimum count" do
          expect do
            expect("<h1>Text</h1>").to have_css('p', minimum: 1)
          end.to raise_error("expected to find css \"p\" at least 1 time but there were no matches")
        end

        it "fails if matched node count is more than expected maximum count" do
          expect do
            expect("<h1>Text</h1><h1>Text</h1><h1>Text</h1>").to have_css('h1', maximum: 2)
          end.to raise_error('expected to find css "h1" at most 2 times, found 3 matches: "Text", "Text", "Text"')
        end

        it "fails if matched node count does not belong to expected range" do
          expect do
            expect("<h1>Text</h1>").to have_css('h1', between: 2..3)
          end.to raise_error("expected to find css \"h1\" between 2 and 3 times, found 1 match: \"Text\"")
        end

      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          expect("<h1>Text</h1>").not_to have_css('h2')
        end

        it "fails if has_no_css? returns false" do
          expect do
            expect("<h1>Text</h1>").not_to have_css('h1')
          end.to raise_error(/expected not to find css "h1"/)
        end

        it "passes if matched node count does not equal expected count" do
          expect("<h1>Text</h1>").not_to have_css('h1', count: 2)
        end

        it "fails if matched node count equals expected count" do
          expect do
            expect("<h1>Text</h1>").not_to have_css('h1', count: 1)
          end.to raise_error(/expected not to find css "h1"/)
        end
      end

      it "supports compounding" do
        expect("<h1>Text</h1><h2>Text</h2>").to have_css('h1').and have_css('h2')
        expect("<h1>Text</h1><h2>Text</h2>").to have_css('h3').or have_css('h1')
      end if RSpec::Version::STRING.to_f >= 3.0
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_css? returns true" do
          expect(page).to have_css('h1')
        end

        it "fails if has_css? returns false" do
          expect do
            expect(page).to have_css('h1#doesnotexist')
          end.to raise_error(/expected to find css "h1#doesnotexist" but there were no matches/)
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          expect(page).not_to have_css('h1#doesnotexist')
        end

        it "fails if has_no_css? returns false" do
          expect do
            expect(page).not_to have_css('h1')
          end.to raise_error(/expected not to find css "h1"/)
        end
      end
    end
  end

  describe "have_xpath matcher" do
    it "gives proper description" do
      expect(have_xpath('//h1').description).to eq("have xpath \"\/\/h1\"")
    end

    context "on a string" do
      context "with should" do
        it "passes if has_xpath? returns true" do
          expect("<h1>Text</h1>").to have_xpath('//h1')
        end

        it "fails if has_xpath? returns false" do
          expect do
            expect("<h1>Text</h1>").to have_xpath('//h2')
          end.to raise_error(%r(expected to find xpath "//h2" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_xpath? returns true" do
          expect("<h1>Text</h1>").not_to have_xpath('//h2')
        end

        it "fails if has_no_xpath? returns false" do
          expect do
            expect("<h1>Text</h1>").not_to have_xpath('//h1')
          end.to raise_error(%r(expected not to find xpath "//h1"))
        end
      end

      it "supports compounding" do
        expect("<h1>Text</h1><h2>Text</h2>").to have_xpath('//h1').and have_xpath('//h2')
        expect("<h1>Text</h1><h2>Text</h2>").to have_xpath('//h3').or have_xpath('//h1')
      end if RSpec::Version::STRING.to_f >= 3.0
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_xpath? returns true" do
          expect(page).to have_xpath('//h1')
        end

        it "fails if has_xpath? returns false" do
          expect do
            expect(page).to have_xpath("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected to find xpath "//h1\[@id='doesnotexist'\]" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_xpath? returns true" do
          expect(page).not_to have_xpath('//h1[@id="doesnotexist"]')
        end

        it "fails if has_no_xpath? returns false" do
          expect do
            expect(page).not_to have_xpath('//h1')
          end.to raise_error(%r(expected not to find xpath "//h1"))
        end
      end
    end
  end

  describe "have_selector matcher" do
    it "gives proper description" do
      matcher = have_selector('//h1')
      expect("<h1>Text</h1>").to matcher
      expect(matcher.description).to eq("have xpath \"//h1\"")
    end

    context "on a string" do
      context "with should" do
        it "passes if has_selector? returns true" do
          expect("<h1>Text</h1>").to have_selector('//h1')
        end

        it "fails if has_selector? returns false" do
          expect do
            expect("<h1>Text</h1>").to have_selector('//h2')
          end.to raise_error(%r(expected to find xpath "//h2" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_selector? returns true" do
          expect("<h1>Text</h1>").not_to have_selector(:css, 'h2')
        end

        it "fails if has_no_selector? returns false" do
          expect do
            expect("<h1>Text</h1>").not_to have_selector(:css, 'h1')
          end.to raise_error(%r(expected not to find css "h1"))
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_selector? returns true" do
          expect(page).to have_selector('//h1', text: 'test')
        end

        it "fails if has_selector? returns false" do
          expect do
            expect(page).to have_selector("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected to find xpath "//h1\[@id='doesnotexist'\]" but there were no matches))
        end

        it "includes text in error message" do
          expect do
            expect(page).to have_selector("//h1", text: 'wrong text')
          end.to raise_error(%r(expected to find xpath "//h1" with text "wrong text" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          expect(page).not_to have_selector(:css, 'h1#doesnotexist')
        end

        it "fails if has_no_selector? returns false" do
          expect do
            expect(page).not_to have_selector(:css, 'h1', text: 'test')
          end.to raise_error(%r(expected not to find css "h1" with text "test"))
        end
      end
    end

    it "supports compounding" do
      expect("<h1>Text</h1><h2>Text</h2>").to have_selector('//h1').and have_selector('//h2')
      expect("<h1>Text</h1><h2>Text</h2>").to have_selector('//h3').or have_selector('//h1')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_content matcher" do
    it "gives proper description" do
      expect(have_content('Text').description).to eq("text \"Text\"")
    end

    context "on a string" do
      context "with should" do
        it "passes if has_content? returns true" do
          expect("<h1>Text</h1>").to have_content('Text')
        end

        it "passes if has_content? returns true using regexp" do
          expect("<h1>Text</h1>").to have_content(/ext/)
        end

        it "fails if has_content? returns false" do
          expect do
            expect("<h1>Text</h1>").to have_content('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "Text"/)
        end
      end

      context "with should_not" do
        it "passes if has_no_content? returns true" do
          expect("<h1>Text</h1>").not_to have_content('No such Text')
        end

        it "passes because escapes any characters that would have special meaning in a regexp" do
          expect("<h1>Text</h1>").not_to have_content('.')
        end

        it "fails if has_no_content? returns false" do
          expect do
            expect("<h1>Text</h1>").not_to have_content('Text')
          end.to raise_error(/expected not to find text "Text" in "Text"/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_content? returns true" do
          expect(page).to have_content('This is a test')
        end

        it "passes if has_content? returns true using regexp" do
          expect(page).to have_content(/test/)
        end

        it "fails if has_content? returns false" do
          expect do
            expect(page).to have_content('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
        end

        context "with default selector CSS" do
          before { Capybara.default_selector = :css }
          it "fails if has_content? returns false" do
            expect do
              expect(page).to have_content('No such Text')
            end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
          end
          after { Capybara.default_selector = :xpath }
        end
      end

      context "with should_not" do
        it "passes if has_no_content? returns true" do
          expect(page).not_to have_content('No such Text')
        end

        it "fails if has_no_content? returns false" do
          expect do
            expect(page).not_to have_content('This is a test')
          end.to raise_error(/expected not to find text "This is a test"/)
        end
      end
    end

    it "supports compounding" do
      expect("<h1>Text</h1><h2>And</h2>").to have_content('Text').and have_content('And')
      expect("<h1>Text</h1><h2>Or</h2>").to have_content('XYZ').or have_content('Or')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_text matcher" do
    it "gives proper description" do
      expect(have_text('Text').description).to eq("text \"Text\"")
    end

    context "on a string" do
      context "with should" do
        it "passes if text contains given string" do
          expect("<h1>Text</h1>").to have_text('Text')
        end

        it "passes if text matches given regexp" do
          expect("<h1>Text</h1>").to have_text(/ext/)
        end

        it "fails if text doesn't contain given string" do
          expect do
            expect("<h1>Text</h1>").to have_text('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "Text"/)
        end

        it "fails if text doesn't match given regexp" do
          expect do
            expect("<h1>Text</h1>").to have_text(/No such Text/)
          end.to raise_error('expected to find text matching /No such Text/ in "Text"')
        end

        it "casts Integer to string" do
          expect do
            expect("<h1>Text</h1>").to have_text(3)
          end.to raise_error(/expected to find text "3" in "Text"/)
        end

        it "fails if matched text count does not equal to expected count" do
          expect do
            expect("<h1>Text</h1>").to have_text('Text', count: 2)
          end.to raise_error('expected to find text "Text" 2 times but found 1 time in "Text"')
        end

        it "fails if matched text count is less than expected minimum count" do
          expect do
            expect("<h1>Text</h1>").to have_text('Lorem', minimum: 1)
          end.to raise_error('expected to find text "Lorem" at least 1 time but found 0 times in "Text"')
        end

        it "fails if matched text count is more than expected maximum count" do
          expect do
            expect("<h1>Text TextText</h1>").to have_text('Text', maximum: 2)
          end.to raise_error('expected to find text "Text" at most 2 times but found 3 times in "Text TextText"')
        end

        it "fails if matched text count does not belong to expected range" do
          expect do
            expect("<h1>Text</h1>").to have_text('Text', between: 2..3)
          end.to raise_error('expected to find text "Text" between 2 and 3 times but found 1 time in "Text"')
        end
      end

      context "with should_not" do
        it "passes if text doesn't contain a string" do
          expect("<h1>Text</h1>").not_to have_text('No such Text')
        end

        it "passes because escapes any characters that would have special meaning in a regexp" do
          expect("<h1>Text</h1>").not_to have_text('.')
        end

        it "fails if text contains a string" do
          expect do
            expect("<h1>Text</h1>").not_to have_text('Text')
          end.to raise_error(/expected not to find text "Text" in "Text"/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_text? returns true" do
          expect(page).to have_text('This is a test')
        end

        it "passes if has_text? returns true using regexp" do
          expect(page).to have_text(/test/)
        end

        it "can check for all text" do
          expect(page).to have_text(:all, 'Some of this text is hidden!')
        end

        it "can check for visible text" do
          expect(page).to have_text(:visible, 'Some of this text is')
          expect(page).not_to have_text(:visible, 'Some of this text is hidden!')
        end

        it "fails if has_text? returns false" do
          expect do
            expect(page).to have_text('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
        end

        context "with default selector CSS" do
          before { Capybara.default_selector = :css }
          it "fails if has_text? returns false" do
            expect do
              expect(page).to have_text('No such Text')
            end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
          end
          after { Capybara.default_selector = :xpath }
        end
      end

      context "with should_not" do
        it "passes if has_no_text? returns true" do
          expect(page).not_to have_text('No such Text')
        end

        it "fails if has_no_text? returns false" do
          expect do
            expect(page).not_to have_text('This is a test')
          end.to raise_error(/expected not to find text "This is a test"/)
        end
      end
    end

    it "supports compounding" do
      expect("<h1>Text</h1><h2>And</h2>").to have_text('Text').and have_text('And')
      expect("<h1>Text</h1><h2>Or</h2>").to have_text('Not here').or have_text('Or')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_link matcher" do
    let(:src) { '<a href="#">Just a link</a><a href="#">Another link</a>' }

    it "gives proper description" do
      expect(have_link('Just a link').description).to eq("have link \"Just a link\"")
    end

    it "passes if there is such a button" do
      expect(src).to have_link('Just a link')
    end

    it "fails if there is no such button" do
      expect do
        expect(src).to have_link('No such Link')
      end.to raise_error(/expected to find link "No such Link"/)
    end

    it "supports compounding" do
      expect(src).to have_link('Just a link').and have_link('Another link')
      expect(src).to have_link('Not a link').or have_link('Another link')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_title matcher" do
    it "gives proper description" do
      expect(have_title('Just a title').description).to eq("have title \"Just a title\"")
    end

    context "on a string" do
      let(:src) { '<title>Just a title</title>' }

      it "passes if there is such a title" do
        expect(src).to have_title('Just a title')
      end

      it "fails if there is no such title" do
        expect do
          expect(src).to have_title('No such title')
        end.to raise_error('expected "Just a title" to include "No such title"')
      end

      it "fails if title doesn't match regexp" do
        expect do
          expect(src).to have_title(/[[:upper:]]+[[:lower:]]+l{2}o/)
        end.to raise_error('expected "Just a title" to match /[[:upper:]]+[[:lower:]]+l{2}o/')
      end
    end

    context "on a page or node" do
      it "passes if there is such a title" do
        visit('/with_js')
        expect(page).to have_title('with_js')
      end

      it "fails if there is no such title" do
        visit('/with_js')
        expect do
          expect(page).to have_title('No such title')
        end.to raise_error('expected "with_js" to include "No such title"')
      end

      context 'with wait' do
        before(:each) do
          @session = session
          @session.visit('/with_js')
        end

        it 'waits if wait time is more than timeout' do
          @session.click_link("Change title")
          using_wait_time 0 do
            expect(@session).to have_title('changed title', wait: 0.5)
          end
        end

        it "doesn't wait if wait time is less than timeout" do
          @session.click_link("Change title")
          using_wait_time 0 do
            expect(@session).not_to have_title('changed title')
          end
        end
      end
    end

    it "supports compounding" do
      expect("<title>I compound</title>").to have_title('I dont compound').or have_title('I compound')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_current_path matcher" do
    it "gives proper description" do
      expect(have_current_path('http://www.example.com').description).to eq("have current path \"http://www.example.com\"")
    end

    context "on a page or node" do
      it "passes if there is such a current path" do
        visit('/with_js')
        expect(page).to have_current_path('/with_js')
      end

      it "fails if there is no such current_path" do
        visit('/with_js')
        expect do
          expect(page).to have_current_path('/not_with_js')
        end.to raise_error('expected "/with_js" to equal "/not_with_js"')
      end

      context 'with wait' do
        before(:each) do
          @session = session
          @session.visit('/with_js')
        end

        it 'waits if wait time is more than timeout' do
          @session.click_link("Change page")
          using_wait_time 0 do
            expect(@session).to have_current_path('/with_html', wait: 1)
          end
        end

        it "doesn't wait if wait time is less than timeout" do
          @session.click_link("Change page")
          using_wait_time 0 do
            expect(@session).not_to have_current_path('/with_html')
          end
        end
      end
    end

    it "supports compounding" do
      visit('/with_html')
      expect(page).to have_current_path('/not_with_html').or have_current_path('/with_html')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_button matcher" do
    let(:src) { '<button>A button</button><input type="submit" value="Another button"/>' }

    it "gives proper description" do
      expect(have_button('A button').description).to eq("have button \"A button\"")
    end

    it "passes if there is such a button" do
      expect(src).to have_button('A button')
    end

    it "fails if there is no such button" do
      expect do
        expect(src).to have_button('No such Button')
      end.to raise_error(/expected to find button "No such Button"/)
    end

    it "supports compounding" do
      expect(src).to have_button('Not this button').or have_button('A button')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_field matcher" do
    let(:src) { '<p><label>Text field<input type="text" value="some value"/></label></p>' }

    it "gives proper description" do
      expect(have_field('Text field').description).to eq("have field \"Text field\"")
    end

    it "gives proper description for a given value" do
      expect(have_field('Text field', with: 'some value').description).to eq("have field \"Text field\" with value \"some value\"")
    end

    it "passes if there is such a field" do
      expect(src).to have_field('Text field')
    end

    it "passes if there is such a field with value" do
      expect(src).to have_field('Text field', with: 'some value')
    end

    it "fails if there is no such field" do
      expect do
        expect(src).to have_field('No such Field')
      end.to raise_error(/expected to find field "No such Field"/)
    end

    it "fails if there is such field but with false value" do
      expect do
        expect(src).to have_field('Text field', with: 'false value')
      end.to raise_error(/expected to find field "Text field"/)
    end

    it "treats a given value as a string" do
      class Foo
        def to_s
          "some value"
        end
      end
      expect(src).to have_field('Text field', with: Foo.new)
    end

    it "supports compounding" do
      expect(src).to have_field('Not this one').or have_field('Text field')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_checked_field matcher" do
    let(:src) do
      '<label>it is checked<input type="checkbox" checked="checked"/></label>
      <label>unchecked field<input type="checkbox"/></label>'
    end

    it "gives proper description" do
      expect(have_checked_field('it is checked').description).to eq("have field \"it is checked\" that is checked")
    end

    context "with should" do
      it "passes if there is such a field and it is checked" do
        expect(src).to have_checked_field('it is checked')
      end

      it "fails if there is such a field but it is not checked" do
        expect do
          expect(src).to have_checked_field('unchecked field')
        end.to raise_error(/expected to find field "unchecked field"/)
      end

      it "fails if there is no such field" do
        expect do
          expect(src).to have_checked_field('no such field')
        end.to raise_error(/expected to find field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is checked" do
        expect do
          expect(src).not_to have_checked_field('it is checked')
        end.to raise_error(/expected not to find field "it is checked"/)
      end

      it "passes if there is such a field but it is not checked" do
        expect(src).not_to have_checked_field('unchecked field')
      end

      it "passes if there is no such field" do
        expect(src).not_to have_checked_field('no such field')
      end
    end

    it "supports compounding" do
      expect(src).to have_checked_field('not this one').or have_checked_field('it is checked')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_unchecked_field matcher" do
    let(:src) do
      '<label>it is checked<input type="checkbox" checked="checked"/></label>
      <label>unchecked field<input type="checkbox"/></label>'
    end

    it "gives proper description" do
      expect(have_unchecked_field('unchecked field').description).to eq("have field \"unchecked field\" that is not checked")
    end

    context "with should" do
      it "passes if there is such a field and it is not checked" do
        expect(src).to have_unchecked_field('unchecked field')
      end

      it "fails if there is such a field but it is checked" do
        expect do
          expect(src).to have_unchecked_field('it is checked')
        end.to raise_error(/expected to find field "it is checked"/)
      end

      it "fails if there is no such field" do
        expect do
          expect(src).to have_unchecked_field('no such field')
        end.to raise_error(/expected to find field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is not checked" do
        expect do
          expect(src).not_to have_unchecked_field('unchecked field')
        end.to raise_error(/expected not to find field "unchecked field"/)
      end

      it "passes if there is such a field but it is checked" do
        expect(src).not_to have_unchecked_field('it is checked')
      end

      it "passes if there is no such field" do
        expect(src).not_to have_unchecked_field('no such field')
      end
    end

    it "supports compounding" do
      expect(src).to have_unchecked_field('it is checked').or have_unchecked_field('unchecked field')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_select matcher" do
    let(:src) { '<label>Select Box<select></select></label>' }

    it "gives proper description" do
      expect(have_select('Select Box').description).to eq("have select box \"Select Box\"")
    end

    it "gives proper description for a given selected value" do
      expect(have_select('Select Box', selected: 'some value').description).to eq("have select box \"Select Box\" with \"some value\" selected")
    end

    it "passes if there is such a select" do
      expect(src).to have_select('Select Box')
    end

    it "fails if there is no such select" do
      expect do
        expect(src).to have_select('No such Select box')
      end.to raise_error(/expected to find select box "No such Select box"/)
    end

    it "supports compounding" do
      expect(src).to have_select('Not this one').or have_select('Select Box')
    end if RSpec::Version::STRING.to_f >= 3.0
  end

  describe "have_table matcher" do
    let(:src) { '<table><caption>Lovely table</caption></table>' }

    it "gives proper description" do
      expect(have_table('Lovely table').description).to eq("have table \"Lovely table\"")
    end

    it "passes if there is such a select" do
      expect(src).to have_table('Lovely table')
    end

    it "fails if there is no such select" do
      expect do
        expect(src).to have_table('No such Table')
      end.to raise_error(/expected to find table "No such Table"/)
    end

    it "supports compounding" do
      expect(src).to have_table('nope').or have_table('Lovely table')
    end if RSpec::Version::STRING.to_f >= 3.0
  end
end
